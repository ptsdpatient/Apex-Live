const express = require('express');
const pool = require('./database'); 
require('dotenv').config();
const app = express();
const port =  process.env.PORT;
const cors = require('cors')
const jwt = require('jsonwebtoken');
const secretKey='apex_live_auth'
const fs = require('fs');
const path = require('path');
const https = require('https')

let index=0


// const sslOptions = {
//     key: fs.readFileSync('/home/apex_live/Apex-Live/certificate/private.key'),
//     cert: fs.readFileSync('/home/apex_live/Apex-Live/certificate/certificate.crt'),
//     ca: fs.readFileSync('/home/apex_live/Apex-Live/certificate/ca_bundle.crt') // Optional, if you have CA bundle
// };

app.use(express.json());
app.options("*",cors());
app.use(cors())


function authenticateToken(req, res, next) {
    // console.log("authenticating")
    const authHeader = req.headers['authorization'];
    let token = authHeader && authHeader.split(' ')[1];
    if (!token) {
        return res.status(401).json({ error: 'Token is missing' }); 
    }

    jwt.verify(token, secretKey, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Token is invalid' }); 
        }
        req.admin= user.isAdmin
        req.user = user.name; 
        req.error = false;
        next(); 
    });
}

app.get('/api/authenticateToken', authenticateToken, (req, res) => {
    // console.log(req.user)
    res.status(200).json({ 
        message: 'Token is valid', 
        error: req.error, 
        name:req.user,
        isAdmin:req.admin,
        done:true,
    });
});

async function alterTableQuery(table, info1, info2, info3, info4,info5, reference) {
    switch (table) {
        case 'cameras': {

            const existingSerial = await pool.query(
                'SELECT id FROM cameras WHERE serial_number = $1',
                [info1]
            );
            
            if (existingSerial.rows.length > 0) {
                return { query:'SELECT 1;', params: [] };

            }

            const trimmed_operator=info3.trim()
            const trimmed_poll_station = info1.trim();
            
            const operator_id_result = await pool.query(
                'SELECT id FROM employees WHERE full_name = $1',
                [trimmed_operator]
            )

            const poll_id_result = await pool.query(
                'SELECT id FROM polling_stations WHERE polling_station_name = $1',
                [trimmed_poll_station]
            );

            if (poll_id_result.rows.length === 0 || operator_id_result.rows.length===0) {
                throw new Error(`No polling station found for ${info1}`);
            }

           
            const query = `
                UPDATE ${table}
                SET serial_number = $1,operator =$2, PS = $3,category = $4
                WHERE id = $5
            `;

            return { query, params: [info1,operator_id_result.rows[0].id, poll_id_result.rows[0].id,info4?"IN":"OUT", reference] };
        };
        case 'polling_stations': {

            console.log(`${info1}`);
            const trimmed_constituency = info3.trim();
            const trimmed_supervisor=info4.trim();

            const constituency_id = await pool.query(
                'SELECT id FROM constituencies WHERE ac_name = $1',
                [trimmed_constituency]
            );
            
            const supervisor_id = await pool.query(
                'SELECT id FROM employees WHERE full_name = $1',
                [trimmed_supervisor]
            )

            if (constituency_id.rows.length === 0 || supervisor_id.rows.length === 0) {
                throw new Error(`No polling station found for ${info3} or ${info4}`);
            }

            
            const query = `
                UPDATE ${table}
                SET polling_station_name = $1, polling_address = $2, supervisor=$3, pid=$4,constituency=$5 
                WHERE id = $6
            `;

            return { query, params: [info1,info2, supervisor_id.rows[0].id,info5,constituency_id.rows[0].id, reference] };
        }
        case 'employees': {
         
            
            const query = `
                UPDATE ${table}
                SET full_name = $1, phone_number = $2, is_admin = $3
                WHERE id = $4
            `;

            return { query, params: [info1,info2 ,info3?1:0 , reference] };
        }
        case 'taluka': {
         
            
            const query = `
                UPDATE ${table}
                SET taluka = $1
                WHERE id = $2
            `;

            return { query, params: [info1, reference] };
        }
        case 'constituencies':{
            const query = `
            UPDATE ${table}
            SET ac_number = $1, ac_name=$2 
            WHERE id = $3
        `;

        return { query, params: [info1, info2, reference] };
        }
    }
}

app.post('/api/editItem', authenticateToken, async (req, res) => {
    const { info1, info2, info3, info4, info5, reference, table } = req.body;

    try {
        // Get the query and parameters
        const { query, params } = await alterTableQuery(table, info1, info2, info3, info4,info5, reference);

        // Execute the query
        const { rows } = await pool.query(query, params);

        res.status(200).json({ done: true, info: table });
        console.log('Table altered : ' +table)
    } catch (err) {
        console.error('error:', err.message);
        res.status(500).json({ done: false, message: err.message });
    }
});


app.post('/api/deleteItem',authenticateToken,async (req,res)=>{
    const {table,reference} =req.body
    console.log('table is : '+table+' reference is : '+reference)

    try{
        const query=`
            DELETE FROM ${table}
            WHERE id = $1
        `
        const { rows } = await pool.query(query, [reference]);
        res.status(200).json({ done: true, info: table });
        console.log('[-] Item deleted : ' +table)

    }catch(err){
        console.log("Error occured : "+err)
    }
})



app.get('/api/getEmployees',async (req,res)=>{
    // console.log('getting emps')
    try{
        const { rows } = await pool.query('SELECT id, full_name, is_admin,phone_number FROM employees');
        res.status(200).json(rows);
    }catch(err){
        res.status(500).json({ error: 'Internal Server Error' });
    }
})

app.get('/api/getTalukas',authenticateToken,async (req,res)=>{
    try{
        const { rows } = await pool.query('SELECT id, taluka FROM taluka');

        res.status(200).json(rows);
    }catch(err){
        res.status(500).json({ error: 'Internal Server Error' });
    }
})


app.get('/api/getCameras',authenticateToken,async (req,res)=>{
    try{
        const query = `        
            SELECT 
                cameras.id AS "camera_id",
                cameras.category AS "category",
                cameras.serial_number AS "serial_number",
                polling_stations.polling_station_name AS "polling_station_name",
                polling_stations.polling_address AS "polling_address",
                polling_stations.pid AS "polling_id",
                employees.full_name AS "supervisor_name",
                employees.phone_number AS "supervisor_phone",
                operator_employee.full_name AS "operator_name",  
                operator_employee.phone_number AS "operator_phone",  
                constituencies.ac_name AS "ac_name",
                constituencies.ac_number AS "ac_number"
            FROM cameras
            LEFT JOIN polling_stations ON cameras.PS = polling_stations.id
            LEFT JOIN employees ON polling_stations.supervisor = employees.id  
            LEFT JOIN employees operator_employee ON cameras.operator = operator_employee.id  
            LEFT JOIN constituencies ON polling_stations.constituency = constituencies.id;
        `;

 
        
        const { rows } = await pool.query(query);
        const modifiedRows = rows.map(row => ({
            ...row,
            muted:true,
            visible: false 
        }));

        res.status(200).json(modifiedRows);

    }catch(err){
        res.status(500).json({ error: 'Internal Server Error' });
    }
})


app.get('/api/',(req,res)=>{
    console.log(`[${index}] port is working`)
    index++
    res.send('endpoint is working!')
})

app.post('/api/myCameraList', authenticateToken, async (req, res) => {
    const { operator } = req.body;
    console.log(operator)
    try {

        const operatorResult = await pool.query(`
            SELECT id FROM employees WHERE full_name = $1;
        `, [operator.trim()]);


        if (operatorResult.rowCount === 0) {
            console.log("employee not found")
            return res.status(404).json({ message: "Employee not found" });
        }

        const operatorId = operatorResult.rows[0].id;
        

        const { rows } = await pool.query(`
            SELECT 
                cameras.id AS "camera_id",
                cameras.serial_number AS "serial_number",
                polling_stations.polling_station_name AS "polling_station_name",
                polling_stations.polling_address AS "polling_address",
                polling_stations.pid AS "polling_id",
                supervisor_employee.full_name AS "supervisor_name",
                supervisor_employee.phone_number AS "supervisor_phone",
                operator_employee.full_name AS "operator_name",
                operator_employee.phone_number AS "operator_phone",
                constituencies.ac_name AS "ac_name",
                constituencies.ac_number AS "ac_number"
            FROM cameras
            LEFT JOIN polling_stations ON cameras.PS = polling_stations.id
            LEFT JOIN employees AS supervisor_employee ON polling_stations.supervisor = supervisor_employee.id  
            LEFT JOIN employees AS operator_employee ON cameras.operator = operator_employee.id  
            LEFT JOIN constituencies ON polling_stations.constituency = constituencies.id
            WHERE 
                polling_stations.supervisor = $1 
                OR cameras.operator = $1;
        `, [operatorId]);


        res.status(200).json(rows);

    } catch (err) {
        console.log("error occurred : "+err)
        return res.status(500).json({ message: "Error occurred: " + err });
    }
});


app.get('/api/getPollingStation',authenticateToken,async (req,res)=>{
    // console.log("getting ps")
    try{
        const query = `         
                        SELECT
                        ps.id AS polling_station_id,
                        ps.pid AS pid,
                        ps.polling_station_name,
                        ps.polling_address,
                        t.taluka AS taluka_name,
                        e.full_name AS supervisor_name,
                        e.phone_number AS supervisor_phone,
                        c.ac_number,
                        c.ac_name,
                        c.taluka AS constituency_taluka_id
                        FROM
                            polling_stations ps
                        LEFT JOIN
                            constituencies c ON ps.constituency = c.id
                        LEFT JOIN
                            taluka t ON c.taluka = t.id
                        LEFT JOIN
                            employees e ON ps.supervisor = e.id;
                    `;

       
        const { rows } = await pool.query(query);
        res.status(200).json(rows);
    }catch(err){
        res.status(500).json({ error: 'Internal Server Error' });
    }
})


app.get('/api/getConstituencies',authenticateToken,async (req,res)=>{
    // console.log("getting constituency")
    try{
        const query = `        
                    SELECT
                    c.id AS constituency_id,
                    c.ac_number,
                    c.ac_name,
                    t.taluka AS taluka_name
                    FROM
                        constituencies c
                    LEFT JOIN
                        taluka t ON c.taluka = t.id                  
        `;
        const { rows } = await pool.query(query);
        // console.log(rows)

        res.status(200).json(rows);
    }catch(err){
        res.status(500).json({ error: 'Internal Server Error' });
    }
})

app.post('/api/registerConstituency',authenticateToken,async (req,res)=>{
    const {number,name,taluka} = req.body
    try{
        const taluka_id = await pool.query('SELECT id FROM taluka WHERE taluka = $1',[taluka])
        const result = await pool.query(
            'INSERT INTO constituencies (ac_number, ac_name, taluka) VALUES ($1, $2, $3) RETURNING ac_name',
            [number,name,taluka_id.rows[0].id]
        );
        const ac_name = result.rows[0].ac_name;
        res.status(200).json({ message: 'Employee registered successfully.', name: ac_name,done:true });
        console.log("$ Constituency registered with AC name : " + ac_name)
    }catch(e){
        console.log("error occured : "+e)
        res.status(201).json({ message: 'Constituency not registered.',done:false });

    }
})

app.post('/api/registerPollingStation',authenticateToken,async (req,res)=>{
    const {name,supervisor,address,constituency,pid} = req.body
    try{

        const supervisor_id = await pool.query('SELECT id FROM employees WHERE full_name = $1',[supervisor])
        const constituency_id = await pool.query('SELECT id FROM constituencies WHERE ac_name = $1',[constituency])
       
        const result = await pool.query(
            'INSERT INTO polling_stations (polling_station_name, pid, polling_address, constituency, supervisor) VALUES ($1, $2, $3, $4,$5) RETURNING polling_station_name',
            [name, pid,address ,constituency_id.rows[0].id,supervisor_id.rows[0].id]
        );

        const PS_address = result.rows[0].polling_station_name;
        res.status(200).json({ message: 'Polling Station registered successfully.', name: PS_address,done:true });
        console.log("$ Polling Station registered with PS name : " + PS_address)
    }catch(e){
        console.log("error occured : "+e)
        res.status(201).json({ message: 'Polling Station not registered.',done:false });

    }
})


app.post('/api/registerCamera',async (req,res)=>{
    // console.log("camera request received")
    const {number,poll_station,operator,category} = req.body
    // if (!number || !poll_station ||!operator) {
    //     console.log("reg error")
    //     return res.status(401).json({ message: 'Camera not registered.', done: false });
    // }

    const trimmed_poll_station = poll_station.trim(); 
    const trimmed_operator= operator.trim()
    // console.log(trimmed_poll_station,trimmed_operator)
    try{
        const operator_id = await pool.query('SELECT id FROM employees WHERE full_name = $1',[trimmed_operator])
        const poll_id = await pool.query('SELECT id FROM polling_stations WHERE polling_station_name = $1',[trimmed_poll_station])
        
        // console.log("pol id got")

       if (poll_id.rowCount === 0) {
        console.log(`-> Polling station "${poll_station}" not found.`);
        return res.status(404).json({ message: 'Polling station not found', done: false });
        }

        const result = await pool.query(
            `INSERT INTO cameras (serial_number, PS ,operator, is_active, category) VALUES ($1, $2, $3, $4, $5) ON CONFLICT (serial_number) DO NOTHING RETURNING serial_number`,
            [number,poll_id.rows[0].id,operator_id.rows[0].id ,0,category?"IN":"OUT"]
        );
        if(result.rows.length > 0){
            const serial_number = result.rows[0].serial_number;
            res.status(200).json({ message: 'Camera registered successfully.', name: serial_number,done:true });
            console.log("$ Camera registered with model name : " + serial_number)
        }else res.status(404).json({done:false})
    }catch(e){
        console.log("error occured : "+e)
        res.status(401).json({ message: 'Camera not registered.',done:false });

    }
})


app.post('/api/registerEmployee',authenticateToken,async (req,res)=>{
    const {name,password,number,isAdmin} = req.body
    
    try{

        const result = await pool.query(
            'INSERT INTO employees (full_name, pass, is_admin, phone_number) VALUES ($1, $2, $3, $4) RETURNING full_name',
            [name, password, isAdmin ? 1 : 0, number]
        );

        const employeeName = result.rows[0].full_name;
        res.status(200).json({ message: 'Employee registered successfully.', name: employeeName,done:true });
        console.log("$ User registered with employee name : " + employeeName)
    }catch(e){
        console.log("error occured : "+e)
        res.status(201).json({ message: 'Employee not registered.',done:false });

    }
})


app.post('/api/registerTaluka',authenticateToken,async (req,res)=>{
    const {name} = req.body
    
    try{

        const result = await pool.query(
            'INSERT INTO taluka (taluka) VALUES ($1) RETURNING taluka',
            [name]
        );

        const talukaName = result.rows[0].taluka;
        res.status(200).json({ message: 'Employee registered successfully.', name: talukaName,done:true });
        console.log("[+] Taluka registered with name : " + talukaName)
    }catch(e){
        console.log("error occured : "+e)
        res.status(201).json({ message: 'Employee not registered.',done:false });

    }
})


app.post('/api/login', async (req, res) => {
    const { name, password } = req.body;

    if (!name || !password) {
        console.log('-> Missing name or password');
        return res.status(400).json({ error: 'name and password are required' });
    }

    try {
        const { rows } = await pool.query('SELECT id, pass, is_admin FROM employees WHERE full_name = $1', [name]);

        if (rows.length === 0) {
            console.log('-> User not found with:', name);
            return res.status(401).json({ error: 'Invalid name or password' });
        }

        const storedPassword = rows[0].pass;

        if (password === storedPassword) {
            const token = jwt.sign({
                 userId: rows[0].id, 
                 name:name,
                 isAdmin: (rows[0].is_admin !== 0) }, 
                 secretKey, { expiresIn: '24h' }
                );
            console.log('-> Login request successful with:', name);
            return res.status(200).json({
                user: {
                    id: rows[0].id,
                    isAdmin: rows[0].is_admin !== 0,
                },
                full_name: name,
                token:token,
                admin: rows[0].is_admin !== 0
            });
        } else {
            return res.status(401).json({ error: 'Invalid name or password' });
        }
    } catch (err) {
        console.error('Error occurred:', err.message);
        return res.status(500).json({ error: 'Internal Server Error' });
    }
});


// https.createServer(sslOptions, app).listen(port,'0.0.0.0', () => {
//     console.log(`\n\n\t\t\x1b[37m[+] Apex Live admin server has started on \x1b[36mhttps://0.0.0.0:${port}\n\x1b[37m`);
// });

app.listen(2000,()=>{
    console.log('server started')
})
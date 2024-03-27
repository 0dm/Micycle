
-- Step 2: Create a new table with the desired schema
DROP TABLE rents;

CREATE TABLE rents (
    bike_id INTEGER,
    start INTEGER,
    end INTEGER,
    user_email VARCHAR,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    FOREIGN KEY (bike_id) REFERENCES bikes (bike_id),
    FOREIGN KEY (start) REFERENCES stations (id),
    FOREIGN KEY (end) REFERENCES stations (id)
);


-- MySQL 8 Spatial Test Script

-- Create test table
CREATE TABLE locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    geom POINT SRID 4326,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    SPATIAL INDEX(geom)
);

-- Generate test data (1 million points)
DELIMITER //
CREATE PROCEDURE generate_test_data()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE categories JSON DEFAULT '["restaurant", "hotel", "park", "shop", "school"]';
    DECLARE category_index INT;
    DECLARE category_name VARCHAR(50);
    DECLARE lon DOUBLE;
    DECLARE lat DOUBLE;
    
    WHILE i <= 1000000 DO
        SET category_index = (i % 5);
        SET category_name = JSON_UNQUOTE(JSON_EXTRACT(categories, CONCAT('$[', category_index, ']')));
        SET lon = -180 + 360 * RAND();
        SET lat = -90 + 180 * RAND();
        
        INSERT INTO locations (name, category, geom)
        VALUES (
            CONCAT('Location ', i),
            category_name,
            ST_SRID(POINT(lon, lat), 4326)
        );
        
        IF i % 10000 = 0 THEN
            SELECT CONCAT('Inserted ', i, ' records') AS progress;
            COMMIT;
        END IF;
        
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- Call the procedure to generate data
CALL generate_test_data();

-- Create index on category for faster filtering
CREATE INDEX idx_locations_category ON locations(category);

-- Analyze table
ANALYZE TABLE locations;

--Find all restaurants within 5km of a specific point
EXPLAIN ANALYZE
SELECT 
    id, 
    name,
    category,
    ST_Distance(
        geom, 
        ST_SRID(POINT(-57.466861, -68.298504), 4326)
    ) * 111195 AS distance_meters
FROM 
    locations
WHERE 
    category = 'restaurant' AND
    ST_Distance(
        geom, 
        ST_SRID(POINT(-57.466861, -68.298504), 4326)
    ) * 111195 <= 5000
ORDER BY 
    distance_meters
;

-- STEP 1 Before making any changes, write a query to inspect the first 10 rows of parts.

SELECT * FROM parts
LIMIT 10;

-- STEP 2 Alter the code column so that each value inserted into this field is unique and not empty.

ALTER TABLE parts
ALTER COLUMN code SET NOT NULL;

ALTER TABLE parts
ADD UNIQUE(code);

-- STEP 3 The parts table is missing values in the description column. Alter the table so that all rows have a value for description.

UPDATE parts
SET description = 'Need Description'
WHERE description IS NULL
  OR description = ' ';

-- STEP 4 To test that you’ve successfully back-filled parts, add a constraint on parts that ensures that all values in description are filled and non-empty.

ALTER TABLE parts
ALTER COLUMN description SET NOT NULL;

-- Check
SELECT * FROM parts
LIMIT 10;

-- STEP 5 Test the constraint by trying to insert a row into parts with the following information. Because you’ve set description to NOT NULL, PostgreSQL should reject this insert. Examine the error and change the description to a different value so that the row can be inserted.

-- INSERT INTO parts (id, code, manufacturer_id) 
-- VALUES (54, 'V1-009', 9)

-- STEP 6 Let’s implement a check that ensures that price_usd and quantity are both NOT NULL. Can you think of some other constraints we might want to add to this table?

ALTER TABLE reorder_options 
ADD CHECK (price_usd IS NOT NULL AND quantity IS NOT NULL);

-- STEP 7 Let’s implement a check that ensures that price_usd and quantity are both positive. Can you think of how to enforce these rules as a single constraint and as two separate constraints?

ALTER TABLE reorder_options
ADD CHECK (price_usd > 0 AND quantity > 0);

-- STEP 8 Let’s assume our storeroom mostly tracks parts with a price per unit between 0.02 USD and 25.00 USD. Add a constraint to reorder_options that limits price per unit to within that range. Assume that price per unit for a given ordering option is the price divided by the quantity.

ALTER TABLE reorder_options
ADD CHECK (price_usd/quantity > 0.02 AND price_usd/quantity < 25.00);

-- STEP 9 Add a constraint to ensure that we don’t have pricing information on parts that aren’t already tracked in our DB schema. Form a relationship between parts and reorder_options that ensures all parts in reorder_options refer to parts tracked in parts.

ALTER TABLE parts
ADD PRIMARY KEY (id);

ALTER TABLE reorder_options 
ADD FOREIGN KEY (part_id) REFERENCES parts(id);

-- STEP 10 The locations table stores information about the locations of a part for all the parts available in our storeroom. Let’s add a constraint that ensures that each value in qty is greater than 0.

ALTER TABLE locations 
ADD CHECK (qty > 0);

-- STEP 11 Let’s ensure that locations records only one row for each combination of location and part. This should make it easier to access information about a location or part from the table. For example, our database should display:

ALTER TABLE locations
ADD UNIQUE (part_id, location);

-- STEP 12 Let’s ensure that for a part to be stored in locations, it must already be registered in parts. Write a constraint that forms the relationship between these two tables and ensures only valid parts are entered into locations.

ALTER TABLE locations
ADD FOREIGN KEY (part_id) REFERENCES parts(id);

-- STEP 13 Let’s ensure that all parts in parts have a valid manufacturer. Write a constraint that forms a relationship between parts and manufacturers that ensures that all parts have a valid manufacturer.

ALTER TABLE parts
ADD FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id);

-- STEP 14 Let’s test the most recent constraint we’ve added. Assume that 'Pip Industrial' and 'NNC Manufacturing' merge and become 'Pip-NNC Industrial'. Create a new manufacturer in manufacturers with an id=11

INSERT INTO manufacturers (name, id)
VALUES ('Pip-NNC Industrial', 11);

-- STEP 15 Update the old manufacturers’ parts in 'parts' to reference the new company you’ve just added to 'manufacturers'.

UPDATE parts
SET manufacturer_id = 11
WHERE manufacturer_id IN (1, 2);
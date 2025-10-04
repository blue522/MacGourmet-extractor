-- This query uses two correlated subqueries to safely and correctly combine
-- the instruction steps and ingredient list into single, ordered, and distinct text fields,
-- thereby eliminating the cross-product duplication error and the DISTINCT syntax error.
SELECT
   r.name AS RecipeName,
   r.source AS Source,


   -- 1. Concatenate all instruction steps from the 'direction' table
   (
       SELECT GROUP_CONCAT(
           -- Concatenate the step text
           T2.directions_text,
           CHAR(10) || CHAR(10)
       )
       FROM direction AS T2
       WHERE T2.recipe_id = r.recipe_id
       -- IMPORTANT: Order by the sort_order column to ensure steps are in the correct sequence.
       ORDER BY T2.sort_order
   ) AS Instructions,


   -- 2. Concatenate all ingredient lines from the 'ingredient' table using a subquery
   (
       SELECT GROUP_CONCAT(
           -- Concatenate quantity, measurement, and description
           T3.quantity || ' ' || T3.measurement || ' ' || T3.description,
           CHAR(10) -- Separator: Single newline
       )
       FROM ingredient AS T3
       WHERE T3.recipe_id = r.recipe_id
       -- IMPORTANT: Order by the sort_order column to ensure ingredients are in the correct sequence.
       ORDER BY T3.sort_order
   ) AS IngredientsList
FROM
   recipe AS r


-- We no longer need the LEFT JOINs on 'direction' and 'ingredient' because all aggregation is done in the subqueries.
-- We keep only the primary table: 'recipe'
-- LEFT JOIN
--    direction AS d ON r.recipe_id = d.recipe_id
-- LEFT JOIN
--    ingredient AS i ON r.recipe_id = i.recipe_id


-- Grouping is no longer needed either, as the subqueries return a single value per row.
-- GROUP BY
--    r.recipe_id, r.name, r.source
ORDER BY
   r.name;





-- ============================================================================
-- MODULE 4: APPLICATION SECURITY - SQL INJECTION EXPLOITATION & MITIGATION
-- ============================================================================

-- 1. VULNERABLE COMPONENT: Constructing code with Dynamic String Concatenation
CREATE OR REPLACE FUNCTION public.get_products_vulnerable(search_term TEXT)
RETURNS TABLE(product_id INT, product_name VARCHAR, category VARCHAR, unit_price NUMERIC) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- The raw string concatenation allows malicious input strings to break out of data context
    RETURN QUERY EXECUTE 'SELECT * FROM public.products WHERE product_name = ''' || search_term || '''';
END;
$$;

-- 2. SECURITY MITIGATION: Constructing code with Native Parameter Binding (Prepared Logic)
CREATE OR REPLACE FUNCTION public.get_products_secure(search_term TEXT)
RETURNS TABLE(product_id INT, product_name VARCHAR, category VARCHAR, unit_price NUMERIC) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- Bound variables are handled strictly as a data literal, eliminating malicious code parsing
    RETURN QUERY 
    SELECT p.product_id, p.product_name, p.category, p.unit_price 
    FROM public.products p 
    WHERE p.product_name = search_term;
END;
$$;

-- ============================================================================
-- SIBER SECURITY PENETRATION TESTING LABORATORY
-- ============================================================================

-- TEST VECTOR A: Executing attack payload against the vulnerable component
-- Payload: 'Smartphone X' OR '1'='1'
-- Expected Result: EXPLOITED. The condition evaluated to TRUE for all rows, returning the full product catalog.
SELECT * FROM public.get_products_vulnerable('Smartphone X'' OR ''1''=''1');

-- TEST VECTOR B: Executing the identical attack payload against the secure component
-- Expected Result: SECURED. Returns an empty grid safely because it searches for a product named literally "'Smartphone X' OR '1'='1'".
SELECT * FROM public.get_products_secure('Smartphone X'' OR ''1''=''1');

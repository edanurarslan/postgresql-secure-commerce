-- ============================================================================
-- MODULE 5: REAL-TIME TRANSACTION AUDITING & LOGGING ARCHITECTURE
-- ============================================================================

-- 1. Create a secure, historical tracking ledger for operational audits
CREATE TABLE public.database_audit_logs (
    audit_id SERIAL PRIMARY KEY,
    target_table VARCHAR(100) NOT NULL,
    action_type VARCHAR(20) NOT NULL,    -- INSERT, UPDATE, or DELETE
    executed_by VARCHAR(100) NOT NULL,    -- Captures exact runtime database identity
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB NULL,                 -- Captures row snapshot PRIOR to operation
    new_data JSONB NULL                  -- Captures row snapshot AFTER operation
);

-- 2. Engine Logic: Develop the trigger procedure to serialize data changes into JSONB format
CREATE OR REPLACE FUNCTION public.log_customer_changes()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO public.database_audit_logs (target_table, action_type, executed_by, old_data)
        VALUES (TG_TABLE_NAME, TG_OP, session_user, to_jsonb(OLD));
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO public.database_audit_logs (target_table, action_type, executed_by, old_data, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, session_user, to_jsonb(OLD), to_jsonb(NEW));
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO public.database_audit_logs (target_table, action_type, executed_by, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, session_user, to_jsonb(NEW));
    END IF;
    RETURN NEW;
END;
$$;

-- 3. Automation Hook: Bind the auditing pipeline to the highly sensitive core asset table
CREATE TRIGGER trg_customers_audit
AFTER INSERT OR UPDATE OR DELETE ON public.customers
FOR EACH ROW
EXECUTE FUNCTION public.log_customer_changes();

-- ============================================================================
-- AUDIT TRAIL VERIFICATION LAB
-- ============================================================================

-- STEP A: Fire a mock transaction altering highly sensitive financial data (Monthly Income)
UPDATE public.customers 
SET monthly_income = 5200.00 
WHERE full_name = 'John Doe';

-- STEP B: Query the audit log pipeline to inspect the immutable security footprint
-- Expected Result: A detailed row illustrating the transaction, showing old salary and new salary in a clear JSON block.
SELECT 
    audit_id, 
    target_table, 
    action_type, 
    executed_by, 
    changed_at, 
    old_data, 
    new_data 
FROM public.database_audit_logs;

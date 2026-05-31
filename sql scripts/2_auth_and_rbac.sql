-- ============================================================================
-- MODULE 2: AUTHENTICATION AND ROLE-BASED ACCESS CONTROL (RBAC)
-- ============================================================================

-- 1. Create Enterprise User Accounts (Authentication)
CREATE USER hr_manager_login WITH PASSWORD 'SecurePassword123!';
CREATE USER intern_login WITH PASSWORD 'BasicPassword123!';

-- 2. Create Functional Security Roles (Authorization)
CREATE ROLE db_hr_manager;
CREATE ROLE db_intern;

-- 3. Provision Permissions to Schema and Tables
GRANT USAGE ON SCHEMA public TO db_hr_manager;
GRANT USAGE ON SCHEMA public TO db_intern;

-- HR Manager Role Privileges: Full CRUD capability over all business assets
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.products TO db_hr_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.customers TO db_hr_manager;

-- Intern Role Privileges: Read-Only access restricted strictly to catalog data
GRANT SELECT ON TABLE public.products TO db_intern;

-- Explicitly enforce isolation by revoking all possible default hooks on sensitive data
REVOKE ALL ON TABLE public.customers FROM db_intern;

-- 4. Map Users to their Respective Structural Roles
GRANT db_hr_manager TO hr_manager_login;
GRANT db_intern TO intern_login;

-- ============================================================================
-- SEGREGATION OF DUTIES (SoD) VERIFICATION TESTS
-- ============================================================================

-- SIMULATION A: Execute under 'hr_manager_login' context
-- Expected Result: Both queries execute successfully with full grid access.
SELECT * FROM public.products;
SELECT * FROM public.customers;

-- SIMULATION B: Execute under 'intern_login' context
-- Expected Result 1: Success. Returns product list.
SELECT * FROM public.products;

-- Expected Result 2: CRITICAL FAILURE (Permission Denied error).
SELECT * FROM public.customers;

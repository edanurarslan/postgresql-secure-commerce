{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 -- ============================================================================\
-- MODULE 2: AUTHENTICATION AND ROLE-BASED ACCESS CONTROL (RBAC)\
-- ============================================================================\
\
-- 1. Create Enterprise User Accounts (Authentication)\
CREATE USER hr_manager_login WITH PASSWORD 'SecurePassword123!';\
CREATE USER intern_login WITH PASSWORD 'BasicPassword123!';\
\
-- 2. Create Functional Security Roles (Authorization)\
CREATE ROLE db_hr_manager;\
CREATE ROLE db_intern;\
\
-- 3. Provision Permissions to Schema and Tables\
GRANT USAGE ON SCHEMA public TO db_hr_manager;\
GRANT USAGE ON SCHEMA public TO db_intern;\
\
-- HR Manager Role Privileges: Full CRUD capability over all business assets\
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.products TO db_hr_manager;\
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.customers TO db_hr_manager;\
\
-- Intern Role Privileges: Read-Only access restricted strictly to catalog data\
GRANT SELECT ON TABLE public.products TO db_intern;\
\
-- Explicitly enforce isolation by revoking all possible default hooks on sensitive data\
REVOKE ALL ON TABLE public.customers FROM db_intern;\
\
-- 4. Map Users to their Respective Structural Roles\
GRANT db_hr_manager TO hr_manager_login;\
GRANT db_intern TO intern_login;\
\
-- ============================================================================\
-- SEGREGATION OF DUTIES (SoD) VERIFICATION TESTS\
-- ============================================================================\
\
-- SIMULATION A: Execute under 'hr_manager_login' context\
-- Expected Result: Both queries execute successfully with full grid access.\
SELECT * FROM public.products;\
SELECT * FROM public.customers;\
\
-- SIMULATION B: Execute under 'intern_login' context\
-- Expected Result 1: Success. Returns product list.\
SELECT * FROM public.products;\
\
-- Expected Result 2: CRITICAL FAILURE (Permission Denied error).\
SELECT * FROM public.customers;}
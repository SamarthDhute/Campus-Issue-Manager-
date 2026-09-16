-- Update seed users with verified BCrypt hash for Password@123
UPDATE users
SET password_hash = '$2a$10$bELZjVrRD8Hg7593hi965.n.DUql9wZOdYuIH1v5pY0u/KmeSt1Ju'
WHERE email IN (
    'admin@smartcampus.edu',
    'manager@smartcampus.edu',
    'teamlead@smartcampus.edu',
    'operator@smartcampus.edu',
    'student@smartcampus.edu'
);

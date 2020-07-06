-- 1 up
create table if not exists users (
  id    integer primary key autoincrement,
  name text,
  email text,
  password  text,
  created_at timestamp,
  updated_at timestamp
);

-- 1 down
drop table if exists users;

-------------------------------------------------------------------
-- Script de criação das tabelas do projeto
-------------------------------------------------------------------

user:
-id
-name
-email
-password
-about
-token
-created


project:
-id
-owner
-name
-description
-link
-created


task:
-id
-owner
-project_id
-assigned
-title
-description
-date
-closed
-created


tag:
-id
-task_id
-name


comment:
-id
-owner
-task_id
-content
-created

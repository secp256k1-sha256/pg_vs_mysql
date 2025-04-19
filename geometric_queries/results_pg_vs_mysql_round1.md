Postgesql Results : 446.637ms 
<img width="694" alt="pg_geo_query" src="https://github.com/user-attachments/assets/1b106917-0b71-4122-b3cf-ad64fcf656ee" />

Mysql Results : 3.122 seconds
<img width="952" alt="mysql_geo_query" src="https://github.com/user-attachments/assets/8b845f99-34cd-434a-9334-d3f37a574a12" />


Postgres is ~7x faster than Mysql for this type of query.


PS: HW was tiny free tier RDS (t4g.micro and 20gb GP3-SSD) for both Postgres and Mysql. Queries were executed multiple times for different parameters to avoid cold disk read issues and AWS fluctuations (if any) on both databases.

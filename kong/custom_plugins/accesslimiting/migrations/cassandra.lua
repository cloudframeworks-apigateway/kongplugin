return {
    {
        name = "2016-12-09-132400_init_accesslimiting",
        up = [[
            CREATE TABLE IF NOT EXISTS accesslimiting_blacklist(
                api_id uuid,
                ip varchar(40),
                PRIMARY KEY (api_id, ip)
            );


            create table if not exists accesslimiting_record(
                api_id uuid,
                ip varchar(40),
                created_at timestamp
            );

            TRUNCATE TABLE accesslimiting_record;
            CREATE INDEX IF NOT EXISTS ON accesslimiting_record(created_at);
        ]],
        down = [[
            DROP TABLE accesslimiting_blacklist;
            DROP TABLE accesslimiting_record;
        ]]
    }
}

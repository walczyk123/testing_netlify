# This is a database user create, finding and authentication exercise

```bash
>> User.create(name: "Kamil Wlcz", email: "wlcz.kml@gmail.end", password: "elo123melo", password_confirmation: "elo123melo")
  User Create (4.9ms)  INSERT INTO "users" ("name", "email", "created_at", "updated_at", "password_digest") VALUES (?, ?, ?, ?, ?)  [["name", "Kamil Wlcz"], ["email", "wlcz.kml@gmail.end"], ["created_at", "2021-03-19 17:23:50.609684"], ["updated_at", "2021-03-19 17:23:50.609684"], ["password_digest", "$2a$12$aIoKJETnS7DDb4vVVzQYS.iDxt3ElBMF5UP92y3kH0wVS0OkwL1FC"]]
=> #<User id: 1, name: "Kamil Wlcz", email: "wlcz.kml@gmail.end", created_at: "2021-03-19 17:23:50.609684000 +0000", updated_at: "2021-03-19 17:23:50.609684000 +0000", password_digest: [FILTERED]>
>> user = User.find_by(name: "Kamil Wlcz")
>> user
=> #<User id: 1, name: "Kamil Wlcz", email: "wlcz.kml@gmail.end", created_at: "2021-03-19 17:23:50.609684000 +0000", updated_at: "2021-03-19 17:23:50.609684000 +0000", password_digest: [FILTERED]>
>> user.valid?
  User Exists? (0.7ms)  SELECT 1 AS one FROM "users" WHERE "users"."email" = ? AND "users"."id" != ? LIMIT ?  [["email", "wlcz.kml@gmail.end"], ["id", 1], ["LIMIT", 1]]
=> false
>> user
=> #<User id: 1, name: "Kamil Wlcz", email: "wlcz.kml@gmail.end", created_at: "2021-03-19 17:23:50.609684000 +0000", updated_at: "2021-03-19 17:23:50.609684000 +0000", password_digest: [FILTERED]>
>> user.password
=> nil
>> user.password_digest
=> "$2a$12$aIoKJETnS7DDb4vVVzQYS.iDxt3ElBMF5UP92y3kH0wVS0OkwL1FC"
>> user.authenticate("elo123melo")
=> #<User id: 1, name: "Kamil Wlcz", email: "wlcz.kml@gmail.end", created_at: "2021-03-19 17:23:50.609684000 +0000", updated_at: "2021-03-19 17:23:50.609684000 +0000", password_digest: [FILTERED]>

```

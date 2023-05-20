# Test users:
[
  { user: "Pippo", department: "Ufficio Marketing" },
  { user: "Pluto", department: "Reparto IT" },
  { user: "Paperino", department: "Backend developer" },
  { user: "Topolino", department: "CEO" }
].each do |u|
  next if User.exists? username: u[ :user ].downcase

  User.create username: u[ :user ].downcase,
    password: "password",
    display_name: u[ :user ],
    department: u[ :department ]
end
puts "Users:  #{User.all.pluck( :username ).sort.join ", "}"


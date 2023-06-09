# Create users:
[
  { user: "Pippo", department: "Ufficio Marketing" },
  { user: "Pluto", department: "Reparto IT" },
  { user: "Paperino", department: "Backend developer" },
  { user: "Topolino", department: "CEO" }
].each do |u|
  next if User.exists? username: "#{u[ :user ].downcase}@scialla.eu"

  User.create username: "#{u[ :user ].downcase}@scialla.eu",
    password: "password",
    display_name: u[ :user ],
    department: u[ :department ]
end
puts "Users:  #{User.all.pluck( :username ).sort.join ", "}"

# Create activities:
[
  {
    name: "Gioco dei mimi",
    description: "Il gioco dei mimi",
    min_players: 3,
    max_players: 5
  }
].each do |g|
  next if Activity.exists? name: g[ :name ]
  Activity.create **g
end
puts "Games: #{Activity.all.pluck( :name ).sort.join ", "}"

# Create questions:
Question.destroy_all
[
  "Qual è il tuo film preferito?",
  "Qual è l'ultimo libro che hai letto?"
].each do |q|
  next if Question.exists? text: q
  Question.create text: q
end
puts "Questions: #{Question.count :id}"


puts "Cleaning database..."

Message.destroy_all
Recipe.destroy_all
Chat.destroy_all
User.destroy_all

puts "Database cleaned!"

puts "Creating users..."

natacha = User.create!(
  first_name: "Natacha",
  last_name: "Martin",
  email: "natacha@example.com",
  password: "password123"
)

anouar = User.create!(
  first_name: "Anouar",
  last_name: "Dupont",
  email: "anouar@example.com",
  password: "password123"
)


guest = User.create!(
  first_name: "Guest",
  last_name: "Mini Gaston",
  email: "guest@minigaston.example",
  password: SecureRandom.hex(32)
)

puts "Creating chats..."

chat_raclette = Chat.create!(
  user: natacha,
  title: "Préparer une raclette"
)

chat_carbonara = Chat.create!(
  user: natacha,
  title: "Cuisiner des pâtes à la carbonara"
)

chat_curry = Chat.create!(
  user: natacha,
  title: "Préparer un poulet au curry"
)

chat_fondant = Chat.create!(
  user: natacha,
  title: "Préparer un dessert au chocolat"
)


chat_guest = Chat.create!(
  user: guest,
  title: "Découvrir les recettes Mini Gaston"
)


puts "Creating recipes..."

Recipe.create!(
  user: natacha,
  chat: chat_raclette,
  title: "Raclette",
  ingredients: "800 g de fromage à raclette, 1 kg de pommes de terre, 400 g de charcuterie, cornichons",
  steps: <<~TEXT,
    1. Laver les pommes de terre.
    2. Faire cuire les pommes de terre pendant 25 minutes.
    3. Disposer la charcuterie et le fromage sur un plateau.
    4. Faire fondre le fromage dans l'appareil à raclette.
    5. Servir avec les pommes de terre et les cornichons.
  TEXT
  duration_in_minutes: 40,
  difficulty: "Facile",
  servings: 4
)

Recipe.create!(
  user: natacha,
  chat: chat_carbonara,
  title: "Pâtes à la carbonara",
  ingredients: "400 g de spaghetti, 4 jaunes d'œufs, 100 g de pecorino, 200 g de guanciale, poivre",
  steps: <<~TEXT,
    1. Faire cuire les spaghetti dans une casserole d'eau bouillante.
    2. Couper le guanciale et le faire revenir à la poêle.
    3. Mélanger les jaunes d'œufs avec le pecorino et le poivre.
    4. Égoutter les pâtes en conservant un peu d'eau de cuisson.
    5. Mélanger les pâtes avec le guanciale et la préparation aux œufs hors du feu.
    6. Servir immédiatement.
  TEXT
  duration_in_minutes: 25,
  difficulty: "Moyen",
  servings: 2
)

Recipe.create!(
  user: natacha,
  chat: chat_curry,
  title: "Poulet au curry",
  ingredients: "500 g de poulet, 400 ml de lait de coco, 2 cuillères à soupe de curry, 250 g de riz, 1 oignon, 2 gousses d'ail, huile d'olive",
  steps: <<~TEXT,
    1. Émincer l'oignon et l'ail.
    2. Couper le poulet en morceaux.
    3. Faire revenir l'oignon et l'ail dans une poêle.
    4. Ajouter le poulet et le curry.
    5. Verser le lait de coco et laisser mijoter pendant 20 minutes.
    6. Faire cuire le riz.
    7. Servir le poulet au curry accompagné du riz.
  TEXT
  duration_in_minutes: 40,
  difficulty: "Facile",
  servings: 3
)

Recipe.create!(
  user: natacha,
  chat: chat_fondant,
  title: "Fondant au chocolat",
  ingredients: "200 g de chocolat noir, 100 g de beurre, 100 g de sucre, 3 œufs, 50 g de farine",
  steps: <<~TEXT,
    1. Préchauffer le four à 180°C.
    2. Faire fondre le chocolat avec le beurre.
    3. Mélanger les œufs et le sucre.
    4. Ajouter le chocolat fondu puis la farine.
    5. Verser la préparation dans des moules individuels.
    6. Enfourner pendant 12 minutes.
    7. Laisser tiédir avant de servir.
  TEXT
  duration_in_minutes: 27,
  difficulty: "Moyen",
  servings: 4
)


puts "Creating Guest demonstration recipes..."

natacha.recipes.each do |recipe|
  Recipe.create!(
    user: guest,
    chat: chat_guest,
    title: recipe.title,
    ingredients: recipe.ingredients,
    steps: recipe.steps,
    duration_in_minutes: recipe.duration_in_minutes,
    difficulty: recipe.difficulty,
    servings: recipe.servings
  )
end

puts "Seeds completed!"
puts "#{User.count} users created"
puts "#{Chat.count} chats created"
puts "#{Recipe.count} recipes created"

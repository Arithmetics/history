json.users @users do |user|
  json.extract! user, :id, :email, :admin
end

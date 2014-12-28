Canard::Abilities.for(:user) do
  can [:read, :auto_complete],          User

  can :create,                          Grocery
  can :manage,                          Grocery,                         user_group_id: @user.user_group_ids

  can :create,                          UserGroup
  can :manage,                          UserGroup,                       id: @user.user_group_ids

  can :create,                          Item
  can :manage,                          Item,                            id: @user.user_groups.flat_map(&:item_ids)
end
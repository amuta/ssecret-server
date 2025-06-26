module Api
  module V1
    class MeController < ApplicationController
      def show
        member_of_array = current_user.groups.joins(:group_memberships).where(group_memberships: { user_id: current_user.id }).distinct.pluck(:id, :name, "group_memberships.encrypted_group_key", :is_personal)

        render json: {
          success: true,
          data: {
            username: current_user.username,
            member_of: member_of_array.map do |group_id, group_name, encrypted_group_key, is_personal|
              {
                id: group_id,
                name: group_name,
                encrypted_group_key: encrypted_group_key,
                is_personal: is_personal
              }
            end
          }
        }
      end
    end
  end
end

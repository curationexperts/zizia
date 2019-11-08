# frozen_string_literal: true
module Zizia
  class Ability
    include Hydra::Ability
    include Hyrax::Ability
    self.ability_logic += [:everyone_can_create_curation_concerns]

    # Define any customized permissions here.
    def custom_permissions
      can :manage, Zizia::CsvImport if current_user.admin?
      can :manage, Zizia::CsvImportDetail if current_user.admin?
      can :manage, Zizia::PreIngestWork if current_user.admin?
    end
  end
end

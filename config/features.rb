# frozen_string_literal: true
Flipflop.configure do
  feature :download_csv,
          default: true,
          description: "Allow the user to download a CSV template from the dashboard."

  feature :import_csv,
          default: true,
          description: "Allow the user to start a CSV import from the dashboard."

  feature :new_ui,
          default: true,
          description: "Show new UI features and workflows."

  feature :read_only,
          default: false,
          description: "Put the system into read-only mode. Deposits, edits, approvals and anything that makes a change to the data will be disabled."
end

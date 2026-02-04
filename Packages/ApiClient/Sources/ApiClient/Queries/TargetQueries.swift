import Foundation

// MARK: - Target Queries

public enum TargetQueries {
    private static let targetFields = """
        id
        name
        emoji
        strategy
        currency
        amount_saved
        amount_target
        expected_start_at
        expected_end_at
        remind_weekly
        remind_monthly
        completed
        archived
        created_at
        updated_at
        """

    public static let listTargets = """
        query listTargets {
            listTargets {
                \(targetFields)
            }
        }
        """

    public static let createTarget = """
        mutation createTarget($input: TargetInput!) {
            createTarget(input: $input) {
                \(targetFields)
            }
        }
        """

    public static let updateTarget = """
        mutation updateTarget($id: String!, $input: TargetInput!) {
            updateTarget(id: $id, input: $input) {
                \(targetFields)
            }
        }
        """
}

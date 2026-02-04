import Testing
@testable import Servicing

@Test func profileCreation() async throws {
    let profile = Profile.makeProfile(name: "Test User", email: "test@example.com")
    #expect(profile.name == "Test User")
    #expect(profile.email == "test@example.com")
    #expect(profile.plan == .free)
}

@Test func transactionCreation() async throws {
    let transaction = Transaction.makeTransaction(name: "Coffee", amount: -5.50)
    #expect(transaction.name == "Coffee")
    #expect(transaction.amount == -5.50)
    #expect(transaction.isExpense)
}

@Test func targetProgress() async throws {
    let target = Target.makeTarget(amountSaved: 500, amountTarget: 1000)
    #expect(target.progress == 0.5)
    #expect(target.progressPercent == 50)
    #expect(target.amountRemaining == 500)
}

@Test func billingProductFormatting() async throws {
    let product = BillingProduct.makeProduct(title: "Premium", price: 9.99)
    #expect(product.title == "Premium")
    #expect(!product.isFree)
    #expect(product.hasTrial)
}

@Test func importJobProgress() async throws {
    let job = ImportFileJob.makeJob(pagesCount: 10, pagesProcessed: 5)
    #expect(job.progress == 0.5)
    #expect(job.progressPercent == 50)
}

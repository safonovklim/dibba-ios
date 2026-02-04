// MARK: - Servicing Module
//
// This module contains domain models and services for the Dibba app.
//
// Models:
// - Profile: User profile with achievements, limits, and subscription info
// - Transaction: Financial transactions with type classification
// - Target: Savings goals with progress tracking
// - Report: Spending reports with category breakdowns
// - BillingProduct: Subscription and purchase products
// - ApiKey: API keys for developer access
// - ImportFileJob: Bank statement import jobs
// - Currency: Currency definitions with regional info
//
// Services:
// - ProfileService: Profile management with in-memory caching
// - TransactionService: Transaction management with file storage caching
// - TargetService: Savings goals management
// - ReportService: Report generation and caching
//
// Caching Strategies:
// - In-Memory (@Shared(.inMemory)): For sensitive data like Profile
// - File Storage (@Shared(.fileStorage)): For list data like Transactions
// - Task Deduplication: Prevents duplicate API calls for same data
//
// Architecture:
// - All services implement StateResetting for logout cleanup
// - AppResetService coordinates batch state reset
// - swift-dependencies for DI

@_exported import Foundation
@_exported import ApiClient
@_exported import Auth
@_exported import Dependencies
@_exported import Sharing

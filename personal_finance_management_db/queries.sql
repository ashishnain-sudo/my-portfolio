-- Add a new account
INSERT INTO accounts (account_name, account_type, balance)
VALUES ('ABC Bank', 'Bank Account', 1000.0);

-- Add a new category
INSERT INTO categories (name) VALUES ('Groceries');

-- Add a new budget plan
INSERT INTO budget_plans (category_id, budget_month, budget_amount)
VALUES (
    (SELECT category_id FROM categories WHERE name = 'Groceries'),
    '2024-08',
    500.00
);

-- Add a new transaction (using subqueries to fetch 'account_id' and 'category_id')
INSERT INTO transactions (account_id, transaction_type, amount, category_id, description)
VALUES (
    (SELECT account_id FROM accounts WHERE account_name = 'ABC Bank'),
    'Expense',
    100.00,
    (SELECT category_id FROM categories WHERE name = 'Groceries'),
    'Grocery shopping'
);

-- Add a new transaction
INSERT INTO transactions (account_id, transaction_date, transaction_type, amount, category_id, description)
VALUES (1, '2024-08-17', 'Expense', 50.00, 1, 'Grocery shopping');

-- Retrieve all accounts with their current balance
SELECT * FROM accounts;

-- Retrieve the recent transactions
SELECT * FROM recent_transactions;

-- Retrieve all transactions for a specific account
SELECT * FROM transactions
WHERE account_id = (SELECT account_id FROM accounts WHERE account_name = 'ABC Bank');

-- Retrieve transactions within a specific date range
SELECT * FROM transactions
WHERE transaction_date BETWEEN '2024-08-01' AND '2024-08-31';

-- Retrieve transactions within a specific category
SELECT * FROM transactions
WHERE category_id = (SELECT category_id FROM categories WHERE name = 'Groceries');

-- Retrieve transactions of a specific type (Income/Expense)
SELECT * FROM transactions
WHERE transaction_type = 'Expense';

-- Show financial summary (total income and expenses) for a specific month
SELECT * FROM monthly_financial_summary
WHERE month = '2024-08';

-- Show financial summary for a specific category and month
SELECT * FROM category_summary
WHERE category_id = (SELECT category_id FROM categories WHERE name = 'Groceries')
AND month = '2024-08';

-- List all categories
SELECT * FROM categories;

-- Show planned budget vs actual spent amount for all categores for a specific month
SELECT *
FROM budget_vs_actual
WHERE month = '2024-08';

-- Represent accounts of the user
CREATE TABLE accounts (
    account_id INTEGER PRIMARY KEY,
    account_name TEXT NOT NULL UNIQUE,
    account_type TEXT, -- e.g., Bank Account, Credit Card, Cash, etc.
    balance REAL NOT NULL DEFAULT 0.0
);

-- Represent categories for transactions (expense and income) and budget plans
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE -- Category name, e.g., Groceries, Entertainment
);

-- Represent individual transactions
CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY,
    account_id INTEGER NOT NULL,
    transaction_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    transaction_type TEXT CHECK(transaction_type IN ('Income', 'Expense')) NOT NULL,
    amount REAL NOT NULL CHECK(amount > 0), -- Amount of the transaction
    category_id INTEGER, -- Optional category for the transaction
    description TEXT, -- Description of the transaction
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Represent budget plans, linked to categories
CREATE TABLE budget_plans (
    budget_id INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL,
    budget_month TEXT NOT NULL DEFAULT (strftime('%Y-%m', 'now')), -- Format: 'YYYY-MM', e.g '2024-08'
    budget_amount REAL NOT NULL, -- Budgeted amount for the category
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    UNIQUE (category_id, budget_month)
);

-- Trigger to automatically update account balance after a transaction is inserted
CREATE TRIGGER after_transaction_insert_update_balance
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    UPDATE accounts
    SET balance = balance +
        CASE
            WHEN NEW.transaction_type = 'Expense' THEN -NEW.amount
            ELSE NEW.amount
        END
    WHERE account_id = NEW.account_id;
END;


-- View to show total spending and income by month
CREATE VIEW monthly_financial_summary AS
SELECT strftime('%Y-%m', transaction_date) AS month, -- Format: 'YYYY-MM', e.g '2024-08'
       SUM(CASE WHEN transaction_type = 'Expense' THEN amount ELSE 0 END) AS total_expense,
       SUM(CASE WHEN transaction_type = 'Income' THEN amount ELSE 0 END) AS total_income
FROM transactions
GROUP BY month;

-- View to summarize the budget and actual spending by category and month
CREATE VIEW budget_vs_actual AS
SELECT bp.category_id,
       c.name AS category_name,
       strftime('%Y-%m', t.transaction_date) AS month, -- Format: 'YYYY-MM', e.g '2024-08'
       bp.budget_amount AS budget_amount,
       COALESCE(SUM(CASE WHEN t.transaction_type = 'Expense' THEN t.amount ELSE -t.amount END), 0) AS actual_spent
FROM budget_plans bp
LEFT JOIN categories c ON bp.category_id = c.category_id
LEFT JOIN transactions t ON bp.category_id = t.category_id
AND strftime('%Y-%m', t.transaction_date) = bp.budget_month
GROUP BY bp.category_id, month;

-- View to show recent transactions
CREATE VIEW recent_transactions AS
SELECT t.transaction_id,
       t.account_id,
       a.account_name,
       t.transaction_date,
       t.transaction_type,
       t.amount,
       t.category_id,
       c.name AS category_name,
       t.description
FROM transactions t
LEFT JOIN accounts a ON t.account_id = a.account_id
LEFT JOIN categories c ON t.category_id = c.category_id
ORDER BY t.transaction_date DESC
LIMIT 10;

-- View to show category summary by month
CREATE VIEW category_summary AS
SELECT strftime('%Y-%m', t.transaction_date) AS month, -- Format: 'YYYY-MM', e.g '2024-08'
       c.category_id,
       c.name AS category_name,
       SUM(CASE WHEN t.transaction_type = 'Expense' THEN t.amount ELSE 0 END) AS total_expense,
       SUM(CASE WHEN t.transaction_type = 'Income' THEN t.amount ELSE 0 END) AS total_income
FROM transactions t
LEFT JOIN categories c ON t.category_id = c.category_id
GROUP BY month, c.category_id;


-- -- Create indexes to speed common searches
CREATE INDEX transactions_date_search ON transactions(transaction_date);
CREATE INDEX transactions_account_id_transaction_date_search ON transactions(account_id, transaction_date);
CREATE INDEX transactions_category_id_transaction_date_search ON transactions(category_id, transaction_date);

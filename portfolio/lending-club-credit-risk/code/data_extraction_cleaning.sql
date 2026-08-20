-- import data
CREATE DATABASE lendingclub;
USE lendingclub;

-- verfiy it worked
select * 
FROM loan
LIMIT 10;

-- populate id column 
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE loan DROP PRIMARY KEY;
ALTER TABLE loan MODIFY COLUMN id INT AUTO_INCREMENT PRIMARY KEY;
SELECT id from loan order by id asc limit 10;
select id from loan order by id desc limit 10;

-- Deciding Variables

select 
	-- individual identifiers
	id AS loan_id,
    loan_status, -- used to determine default
    loan_amnt,
    funded_amnt,
    int_Rate as interest_rate,
    installment as monthly_payment,
    term, -- 36 or 60 months
   
   -- credit risk signals
   grade, -- lending clubs risk grade (a-g)
   sub_grade,
   dti, -- debt to income ratio
   delinq_2yrs, -- delinquincies in the past 2 years
   inq_last_6mths as inquiries_6mo,
   pub_rec as public_records,
   revol_util as revolving_utilization,
   open_acc as open_accounts,
   total_acc as total_accounts,
   
   -- Collateral and purpose
   purpose,
   home_ownership,
   addr_state as state, 
   
   -- customer behavior 
   earliest_cr_Line, -- length of credit history
   emp_length as employment_length,
   annual_inc as annual_income,
   verification_status, 
   
   -- loss given default (LGD)(amount recorved on defaults) variables
   funded_amnt,
   recoveries,
   total_rec_prncp,
   
   
   
   
   -- create default flag  
   
   CASE
        WHEN loan_status IN (
            'Charged Off',
            'Default',
            'Does not meet the credit policy. Status:Charged Off'
        ) THEN 1
        ELSE 0
    END AS default_flag

FROM loan

WHERE
    loan_status IN (
        'Fully Paid',
        'Charged Off',
        'Default',
        'Does not meet the credit policy. Status:Charged Off',
        'Does not meet the credit policy. Status:Fully Paid'
    )                          -- excludes "Current" loans since theres no outcome yet
    AND loan_amnt IS NOT NULL
    AND int_rate  IS NOT NULL
    AND annual_inc > 0

ORDER BY id;
   
   describe loan;
   
   SELECT COUNT(*) FROM loan;
   
SELECT loan_status, COUNT(*) 
FROM loan 
GROUP BY loan_status;



class UpdateFloatingPointPrecision < ActiveRecord::Migration
  def self.up
    execute 'alter table companies modify credit_balance decimal(63,4) default 0.0;'
    execute 'alter table companies modify credits_accrued_mtd decimal(63,4) default 0.0;'
    execute 'alter table companies modify credits_accrued_ytd decimal(63,4) default 0.0;'
    execute 'alter table companies modify best_commission_paid_mtd decimal(63,4) default 0.0;'
    execute 'alter table companies modify best_commission_paid_ytd decimal(63,4) default 0.0;'
    execute 'alter table companies modify soft_commission_paid_mtd decimal(63,4) default 0.0;'
    execute 'alter table companies modify soft_commission_paid_ytd decimal(63,4) default 0.0;'
    execute 'alter table companies modify commission_paid_mtd decimal(63,4) default 0.0;'
    execute 'alter table companies modify commission_paid_ytd decimal(63,4) default 0.0;'

    execute 'alter table invoices modify amount decimal(63,4) default 0.0;'

    execute 'alter table payments modify amount decimal(63,4) default 0.0;'

    execute 'alter table trades modify average_price decimal(63,4) default 0.0;'

    execute 'alter table trades modify credit_accrued decimal(63,4) default 0.0;'
    execute 'alter table trades modify commission_paid decimal(63,4) default 0.0;'
  end

  def self.down
  end
end

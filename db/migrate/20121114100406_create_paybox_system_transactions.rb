class CreatePayboxSystemTransactions < ActiveRecord::Migration
  def change
    create_table :spree_paybox_system_transactions do |t|
      t.integer :amount, :null => false
      t.integer :ref, :null => false, :unique => true
      t.string :auto, :null => false
      t.string :error, :null => false
      t.string :action, :null => false
      t.timestamps
    end
  end
end

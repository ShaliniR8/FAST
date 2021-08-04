task update_verification_overdue_status: :environment do
   Verification.where(status: 'New')
               .where('verify_date < ?', Date.current)
               .update_all(status: 'Overdue')
end

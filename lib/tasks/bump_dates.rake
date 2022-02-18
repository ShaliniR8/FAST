namespace :update_records do

  task :bump_dates => :environment do
    begin
      @logger = Logger.new("log/bumped_dates.log")

      update_hash_ids = Hash.new
      update_hash_fields = Hash.new

      update_hash_ids['Submission'] = Hash.new
      update_hash_fields['Submission'] = Hash.new
      update_hash_ids['Submission'] = [90, 128, 131, 157].uniq
      update_hash_fields['Submission'] = ['event_date'].uniq

      update_hash_ids['Record'] = Hash.new
      update_hash_fields['Record'] = Hash.new
      update_hash_ids['Record'] = [75, 86, 89, 95].uniq
      update_hash_fields['Record'] = ['event_date'].uniq

      update_hash_ids['Meeting'] = Hash.new
      update_hash_fields['Meeting'] = Hash.new
      update_hash_ids['Meeting'] = [4, 7].uniq
      update_hash_fields['Meeting'] = ['meeting_start', 'meeting_end'].uniq

      update_hash_ids['Audit'] = Hash.new
      update_hash_fields['Audit'] = Hash.new
      update_hash_ids['Audit'] = [14, 15].uniq
      update_hash_fields['Audit'] = ['due_date'].uniq

      update_hash_ids['Finding'] = Hash.new
      update_hash_fields['Finding'] = Hash.new
      update_hash_ids['Finding'] = [5, 7].uniq
      update_hash_fields['Finding'] = ['due_date'].uniq

      update_hash_ids['SmsAction'] = Hash.new
      update_hash_fields['SmsAction'] = Hash.new
      update_hash_ids['SmsAction'] = [6, 8].uniq
      update_hash_fields['SmsAction'] = ['due_date'].uniq

      update_hash_ids['Sra'] = Hash.new
      update_hash_fields['Sra'] = Hash.new
      update_hash_ids['Sra'] = [2, 3, 5, 12, 14].uniq
      update_hash_fields['Sra'] = ['due_date'].uniq

      update_hash_ids['RiskControl'] = Hash.new
      update_hash_fields['RiskControl'] = Hash.new
      update_hash_ids['RiskControl'] = [3].uniq
      update_hash_fields['RiskControl'] = ['due_date'].uniq


      update_hash_ids.each do |key, value|
        update_hash_fields[key].each do |field|
          puts "Updating #{field} for #{key} IDs #{value.join(',')}"
          Object.const_get(key).where(id: value).map{|o| o.update_attribute(field, (o.send(field.to_sym) + 1.month))}
        end
      end

    rescue => error
      @logger.info "[ERROR][BUMP_DATES_TASK]: #{error.message}"
    end
  end

  task :create_submissions => [:environment] do |t|
    begin
      @logger = Logger.new("log/submissions_created.log")

      json_hash =  {1 => "{\"anonymous\": false,\"user_id\": 2232,\"templates_id\": 17,\"completed\": true,\"description\": \"Anxiety attack\",\"event_date\": \"2021-10-11T16:51:20.000Z\",\"event_time_zone\": \"Arizona\",\"submission_fields_attributes\": {\"1540\": {\"id\": 0,\"fields_id\": 1540,\"value\": \"2021-10-11T20:51:45.891Z\"},\"1541\": {\"id\": 1,\"fields_id\": 1541,\"value\": \"\"},\"1542\": {\"id\": 2,\"fields_id\": 1542,\"value\": \"Lead Flight Attendant\"},\"1543\": {\"id\": 3,\"fields_id\": 1543,\"value\": \"\"},\"1544\": {\"id\": 5,\"fields_id\": 1544,\"value\": \"606\"},\"1545\": {\"id\": 6,\"fields_id\": 1545,\"value\": \"KMSP;MSP\"},\"1546\": {\"id\": 9,\"fields_id\": 1546,\"value\": \"N831SY\"},\"1547\": {\"id\": 7,\"fields_id\": 1547,\"value\": \"KPHX;PHX\"},\"1549\": {\"id\": 8,\"fields_id\": 1549,\"value\": \"\"},\"1581\": {\"id\": 27,\"fields_id\": 1581,\"value\": \"\"},\"1582\": {\"id\": 28,\"fields_id\": 1582,\"value\": \"\"},\"1583\": {\"id\": 29,\"fields_id\": 1583,\"value\": \"\"},\"1584\": {\"id\": 30,\"fields_id\": 1584,\"value\": \"\"},\"1585\": {\"id\": 31,\"fields_id\": 1585,\"value\": \"\"},\"1589\": {\"id\": 24,\"fields_id\": 1589,\"value\": \"\"},\"1590\": {\"id\": 26,\"fields_id\": 1590,\"value\": \"\"},\"1591\": {\"id\": 16,\"fields_id\": 1591,\"value\": \"\"},\"1592\": {\"id\": 18,\"fields_id\": 1592,\"value\": \"\"},\"1607\": {\"id\": 14,\"fields_id\": 1607,\"value\": \"Passenger in 6F rang her call light after 10,000 ft and asked if she could stand up in the back because she was having a panic attack. She was a young fit woman and said this had never happened before. 2L got her water and pretzels and suggested she put her jjead between her knees. she stayed in the back galley while we prepared our carts then she went back to her seat. We moved her to 6D so she could easy get to the LAV if needed. Before we began service she came up front and asked if she could stay there. She said she felt like she couldn’t breathe. I helped her take longer breaths and offered to rub her back which she accepted. I asked if she wanted to talk. She said yes so we chatted about a variety of things to get her mind off her breathing and then I gave her some ginger ale. I suggested she look at pictures of her kids on her phone which she did while we did our service. She calmed down and was able to share stories with me. She eventually was able to take her seat where she stayed the rest of the flight. We all checked on her often and cheered for her when she got off the plane smiling and thanking us.\"},\"1608\": {\"id\": 15,\"fields_id\": 1608,\"value\": \"We are concerned about this passenger’s return flight and wish we had suggested she get some anti anxiety medication. \"},\"2837\": {\"id\": 10,\"fields_id\": 2837,\"value\": \"Climb\"},\"2838\": {\"id\": 11,\"fields_id\": 2838,\"value\": \"On\"},\"2839\": {\"id\": 12,\"fields_id\": 2839,\"value\": \"99%\"},\"2840\": {\"id\": 23,\"fields_id\": 2840,\"value\": \"\"},\"2841\": {\"id\": 19,\"fields_id\": 2841,\"value\": \"\"},\"2842\": {\"id\": 22,\"fields_id\": 2842,\"value\": \"\"},\"2844\": {\"id\": 17,\"fields_id\": 2844,\"value\": \"\"},\"2845\": {\"id\": 21,\"fields_id\": 2845,\"value\": \"\"},\"2846\": {\"id\": 13,\"fields_id\": 2846,\"value\": \"Beverage Service\"},\"2865\": {\"id\": 20,\"fields_id\": 2865,\"value\": \"\"},\"2975\": {\"id\": 25,\"fields_id\": 2975,\"value\": \"\"},\"2983\": {\"id\": 4,\"fields_id\": 2983,\"value\": \"No\"}}}".to_s,
                    2 => "{\"anonymous\": false,\"user_id\": 2232,\"templates_id\": 17,\"completed\": true,\"description\": \"Passenger knee hurt\",\"event_date\": \"2021-10-18T23:56:07.690Z\",\"event_time_zone\": \"Central Time (US & Canada)\",\"submission_fields_attributes\": {\"1540\": {\"id\": 0,\"fields_id\": 1540,\"value\": \"\"},\"1541\": {\"id\": 1,\"fields_id\": 1541,\"value\": \"\"},\"1542\": {\"id\": 2,\"fields_id\": 1542,\"value\": \"Flight Attendant\"},\"1543\": {\"id\": 3,\"fields_id\": 1543,\"value\": \"1R\"},\"1544\": {\"id\": 5,\"fields_id\": 1544,\"value\": \"106\"},\"1545\": {\"id\": 6,\"fields_id\": 1545,\"value\": \"KLAS;LAS\"},\"1546\": {\"id\": 9,\"fields_id\": 1546,\"value\": \"N837SY\"},\"1547\": {\"id\": 7,\"fields_id\": 1547,\"value\": \"KMSP;MSP\"},\"1549\": {\"id\": 8,\"fields_id\": 1549,\"value\": \"\"},\"1581\": {\"id\": 27,\"fields_id\": 1581,\"value\": \"\"},\"1582\": {\"id\": 28,\"fields_id\": 1582,\"value\": \"\"},\"1583\": {\"id\": 29,\"fields_id\": 1583,\"value\": \"\"},\"1584\": {\"id\": 30,\"fields_id\": 1584,\"value\": \"\"},\"1585\": {\"id\": 31,\"fields_id\": 1585,\"value\": \"\"},\"1589\": {\"id\": 24,\"fields_id\": 1589,\"value\": \"\"},\"1590\": {\"id\": 26,\"fields_id\": 1590,\"value\": \"\"},\"1591\": {\"id\": 16,\"fields_id\": 1591,\"value\": \"\"},\"1592\": {\"id\": 18,\"fields_id\": 1592,\"value\": \"\"},\"1607\": {\"id\": 14,\"fields_id\": 1607,\"value\": \"While pushing the BOB down the isle I bumped the cart into a mans leg in 6D. He was tall and had his  knee in the isle which I did not see in the dark plane. Later in the flight he asked me who he could talk to about his knee. I told him he could talk to me and tell me he was mad at me. I apologized and i offered to get him some ice and he said that would be good. I gave him ice and a cookie and he thanked me and laughed.\"},\"1608\": {\"id\": 15,\"fields_id\": 1608,\"value\": \"I think our carts could have rubber bumpers attached so they don’t hurt so bad if we hit a body part. Pushing the BOB cart is worse than pulling a cart because our bodies act as a buffer.\"},\"2837\": {\"id\": 10,\"fields_id\": 2837,\"value\": \"Cruise\"},\"2838\": {\"id\": 11,\"fields_id\": 2838,\"value\": \"\"},\"2839\": {\"id\": 12,\"fields_id\": 2839,\"value\": \"\"},\"2840\": {\"id\": 23,\"fields_id\": 2840,\"value\": \"\"},\"2841\": {\"id\": 19,\"fields_id\": 2841,\"value\": \"\"},\"2842\": {\"id\": 22,\"fields_id\": 2842,\"value\": \"\"},\"2844\": {\"id\": 17,\"fields_id\": 2844,\"value\": \"\"},\"2845\": {\"id\": 21,\"fields_id\": 2845,\"value\": \"\"},\"2846\": {\"id\": 13,\"fields_id\": 2846,\"value\": \"Beverage Service\"},\"2865\": {\"id\": 20,\"fields_id\": 2865,\"value\": \"\"},\"2975\": {\"id\": 25,\"fields_id\": 2975,\"value\": \"\"},\"2983\": {\"id\": 4,\"fields_id\": 2983,\"value\": \"No\"}}}".to_s,
                    3 => "{\"anonymous\": false,\"user_id\": 2232,\"templates_id\": 17,\"completed\": true,\"description\": \"no soda or bOb carts\",\"event_date\": \"2021-10-21T09:06:57.000Z\",\"event_time_zone\": \"Eastern Time (US & Canada)\",\"submission_fields_attributes\": {\"1540\": {\"id\": 0,\"fields_id\": 1540,\"value\": \"2021-10-21T09:07:16.000Z\"},\"1541\": {\"id\": 1,\"fields_id\": 1541,\"value\": \"\"},\"1542\": {\"id\": 2,\"fields_id\": 1542,\"value\": \"Lead Flight Attendant\"},\"1543\": {\"id\": 3,\"fields_id\": 1543,\"value\": \"\"},\"1544\": {\"id\": 5,\"fields_id\": 1544,\"value\": \"8882\"},\"1545\": {\"id\": 6,\"fields_id\": 1545,\"value\": \"KPHL;PHL\"},\"1546\": {\"id\": 9,\"fields_id\": 1546,\"value\": \"N838SY\"},\"1547\": {\"id\": 7,\"fields_id\": 1547,\"value\": \"KLAS;LAS\"},\"1549\": {\"id\": 8,\"fields_id\": 1549,\"value\": \"\"},\"1581\": {\"id\": 27,\"fields_id\": 1581,\"value\": \"\"},\"1582\": {\"id\": 28,\"fields_id\": 1582,\"value\": \"\"},\"1583\": {\"id\": 29,\"fields_id\": 1583,\"value\": \"\"},\"1584\": {\"id\": 30,\"fields_id\": 1584,\"value\": \"\"},\"1585\": {\"id\": 31,\"fields_id\": 1585,\"value\": \"\"},\"1589\": {\"id\": 24,\"fields_id\": 1589,\"value\": \"\"},\"1590\": {\"id\": 26,\"fields_id\": 1590,\"value\": \"\"},\"1591\": {\"id\": 16,\"fields_id\": 1591,\"value\": \"\"},\"1592\": {\"id\": 18,\"fields_id\": 1592,\"value\": \"\"},\"1607\": {\"id\": 14,\"fields_id\": 1607,\"value\": \"The plane has no soda, water or BoB on board even though the charter flight was scheduled to have that, per the rep for the charter group. GSC Tim was on board when we arrived and told us the he had requested ice, water and soda from the PHL caterers. We received cases of soda (only coke, Diet Coke and sprite) and ice but no water. We had one case of small water bottles from the previous charter that we kept onboard. Tim and the FAs moved all the cases of soda to the back of the plane. The passenger rep for the group was very disappointed and embarrassed about the missing liquor option.  Before service I expressed my sincere apologies for the fact that liquor was not available on the flight due to a catering issue so that the group rep would not be blamed for the error. We had to creatively set up carts with the cases of soda as best we could as we had few drawers. We served whole cans of soda with glasses of ice (sparingly)  to every passenger. We barely had enough ice for the one service. Because we did not have enough bins to hold a coffee pot safely during service, We walked through with coffee after soda service but could not offer water service because we had such a limited supply of water. \"},\"1608\": {\"id\": 15,\"fields_id\": 1608,\"value\": \"We know this plane left MPLS 3 days ago for charters and was not set up for this charter with the proper catering. All we could do was apologize and give full cans of soda to make amends. However, truth be told, EAgles fans are notoriously rowdy and we are relieved not to have liquor on this flight. There are lot of passengers who have their masks down consistently and it would be way worse if they had alcoholic drinks. Maybe sports charters should not allow liquor on flights. \"},\"2837\": {\"id\": 10,\"fields_id\": 2837,\"value\": \"Predeparture/Preflight\"},\"2838\": {\"id\": 11,\"fields_id\": 2838,\"value\": \"\"},\"2839\": {\"id\": 12,\"fields_id\": 2839,\"value\": \"100%\"},\"2840\": {\"id\": 23,\"fields_id\": 2840,\"value\": \"\"},\"2841\": {\"id\": 19,\"fields_id\": 2841,\"value\": \"Catering-Missing/Inadequate Supplies;Catering-Other\"},\"2842\": {\"id\": 22,\"fields_id\": 2842,\"value\": \"\"},\"2844\": {\"id\": 17,\"fields_id\": 2844,\"value\": \"\"},\"2845\": {\"id\": 21,\"fields_id\": 2845,\"value\": \"\"},\"2846\": {\"id\": 13,\"fields_id\": 2846,\"value\": \"Cabin Preparations\"},\"2865\": {\"id\": 20,\"fields_id\": 2865,\"value\": \"\"},\"2975\": {\"id\": 25,\"fields_id\": 2975,\"value\": \"\"},\"2983\": {\"id\": 4,\"fields_id\": 2983,\"value\": \"No\"}}}".to_s,
                    4 => "{\"anonymous\": false,\"user_id\": 2232,\"templates_id\": 17,\"completed\": true,\"description\": \"Passenger walker\",\"event_date\": \"2021-10-25T20:07:22.000Z\",\"event_time_zone\": \"Eastern Time (US & Canada)\",\"submission_fields_attributes\": {\"1540\": {\"id\": 0,\"fields_id\": 1540,\"value\": \"2021-10-25T20:07:45.000Z\"},\"1541\": {\"id\": 1,\"fields_id\": 1541,\"value\": \"\"},\"1542\": {\"id\": 2,\"fields_id\": 1542,\"value\": \"Flight Attendant\"},\"1543\": {\"id\": 3,\"fields_id\": 1543,\"value\": \"\"},\"1544\": {\"id\": 5,\"fields_id\": 1544,\"value\": \"345\"},\"1545\": {\"id\": 6,\"fields_id\": 1545,\"value\": \"KMSP;MSP\"},\"1546\": {\"id\": 9,\"fields_id\": 1546,\"value\": \"N832SY\"},\"1547\": {\"id\": 7,\"fields_id\": 1547,\"value\": \"KMCO;MCO\"},\"1549\": {\"id\": 8,\"fields_id\": 1549,\"value\": \"\"},\"1581\": {\"id\": 27,\"fields_id\": 1581,\"value\": \"\"},\"1582\": {\"id\": 28,\"fields_id\": 1582,\"value\": \"\"},\"1583\": {\"id\": 29,\"fields_id\": 1583,\"value\": \"\"},\"1584\": {\"id\": 30,\"fields_id\": 1584,\"value\": \"\"},\"1585\": {\"id\": 31,\"fields_id\": 1585,\"value\": \"\"},\"1589\": {\"id\": 24,\"fields_id\": 1589,\"value\": \"\"},\"1590\": {\"id\": 26,\"fields_id\": 1590,\"value\": \"\"},\"1591\": {\"id\": 16,\"fields_id\": 1591,\"value\": \"\"},\"1592\": {\"id\": 18,\"fields_id\": 1592,\"value\": \"\"},\"1607\": {\"id\": 14,\"fields_id\": 1607,\"value\": \"As we were deplaning, passenger in 1D was in a wheelchair waiting for her walker to be unloaded from the plane. She was the last passenger off because she had to wait for the wheelchair. As FAs left the plane we noticed the elderly passenger was in the gate area asking gate agent for help locating her walker. The next morning, as we were monitoring boarding of the charter flight out of the Orlando FBO, we overheard the GSC say that the mechanics found a walker in the hold of the plane. I told the CA that the walker likely belonged to our passenger from last night. He called SOC and reported that we were leaving the walker at the FBO. \"},\"1608\": {\"id\": 15,\"fields_id\": 1608,\"value\": \"The 1D passenger shared with us during the flight that her husband was killed in a car accident on 35W recently. She was traveling with her daughter and grand baby and  3 Yr old grandson. The young mother had her hands full to overflowing with bags and kids and her elderly mother. I cannot imagine how difficult it would have been for her to manage everything, especially helping her mom without the help of the much needed walker. Apparently the ground  crew failed to locate the walker last night.\"},\"2837\": {\"id\": 10,\"fields_id\": 2837,\"value\": \"Predeparture/Preflight\"},\"2838\": {\"id\": 11,\"fields_id\": 2838,\"value\": \"\"},\"2839\": {\"id\": 12,\"fields_id\": 2839,\"value\": \"\"},\"2840\": {\"id\": 23,\"fields_id\": 2840,\"value\": \"\"},\"2841\": {\"id\": 19,\"fields_id\": 2841,\"value\": \"\"},\"2842\": {\"id\": 22,\"fields_id\": 2842,\"value\": \"\"},\"2844\": {\"id\": 17,\"fields_id\": 2844,\"value\": \"\"},\"2845\": {\"id\": 21,\"fields_id\": 2845,\"value\": \"\"},\"2846\": {\"id\": 13,\"fields_id\": 2846,\"value\": \"Passenger Boarding\"},\"2865\": {\"id\": 20,\"fields_id\": 2865,\"value\": \"\"},\"2975\": {\"id\": 25,\"fields_id\": 2975,\"value\": \"\"},\"2983\": {\"id\": 4,\"fields_id\": 2983,\"value\": \"No\"}}}".to_s,
                    5 => "{\"anonymous\": false,\"user_id\": 2232,\"templates_id\": 17,\"completed\": true,\"description\": \"Exit row & wheelchair\",\"event_date\": \"2021-11-01T11:33:31.000Z\",\"event_time_zone\": \"Central Time (US & Canada)\",\"submission_fields_attributes\": {\"1540\": {\"id\": 0,\"fields_id\": 1540,\"value\": \"2021-11-01T10:34:14.000Z\"},\"1541\": {\"id\": 1,\"fields_id\": 1541,\"value\": \"\"},\"1542\": {\"id\": 2,\"fields_id\": 1542,\"value\": \"Flight Attendant\"},\"1543\": {\"id\": 3,\"fields_id\": 1543,\"value\": \"1R\"},\"1544\": {\"id\": 5,\"fields_id\": 1544,\"value\": \"387\"},\"1545\": {\"id\": 6,\"fields_id\": 1545,\"value\": \"KMSP;MSP\"},\"1546\": {\"id\": 9,\"fields_id\": 1546,\"value\": \"Not Applicable\"},\"1547\": {\"id\": 7,\"fields_id\": 1547,\"value\": \"KRSW;RSW\"},\"1549\": {\"id\": 8,\"fields_id\": 1549,\"value\": \"\"},\"1581\": {\"id\": 27,\"fields_id\": 1581,\"value\": \"\"},\"1582\": {\"id\": 28,\"fields_id\": 1582,\"value\": \"\"},\"1583\": {\"id\": 29,\"fields_id\": 1583,\"value\": \"\"},\"1584\": {\"id\": 30,\"fields_id\": 1584,\"value\": \"\"},\"1585\": {\"id\": 31,\"fields_id\": 1585,\"value\": \"\"},\"1589\": {\"id\": 24,\"fields_id\": 1589,\"value\": \"\"},\"1590\": {\"id\": 26,\"fields_id\": 1590,\"value\": \"\"},\"1591\": {\"id\": 16,\"fields_id\": 1591,\"value\": \"\"},\"1592\": {\"id\": 18,\"fields_id\": 1592,\"value\": \"\"},\"1607\": {\"id\": 14,\"fields_id\": 1607,\"value\": \"Gate agent gave LFA a briefing and said a passenger in the exit row needed a wheelchair in RSW. She said they could not legally sit there if they needed a wheelchair. The gate agent said they were not allowed to deny a passenger who paid extra from sitting in the exit row. When the LFA said that was FAA rules a gate agent supervisor was called down and brought a print out of their instructions which way a passenger who pays for a seat cannot be denied that exit row seat if they claim they can help in an emergency. The passenger was allowed to sit in the exit row.\"},\"1608\": {\"id\": 15,\"fields_id\": 1608,\"value\": \"We have a conflict with the gate agents; it is our lives and the passengers lives that are at risk if a passenger can’t  climb out the window and walk away from the plane quickly in the event of an emergency. Our rules and the gate agent rules must be the same. Perhaps there needs to be a more thorough questionnaire for those paying extra for an exit row seat. Get specific on the duties outlined on the safety information card and specifically say that they will be denied that seat if the FAs deem them unfit for this purpose in the event that they lie just to get extra leg space. State clearly that anyone needing wheelchair assistance for boarding or on arrival at their destination will not be allowed to sit in the exit seat, even if they pay.  \"},\"2837\": {\"id\": 10,\"fields_id\": 2837,\"value\": \"Predeparture/Preflight\"},\"2838\": {\"id\": 11,\"fields_id\": 2838,\"value\": \"\"},\"2839\": {\"id\": 12,\"fields_id\": 2839,\"value\": \"100\"},\"2840\": {\"id\": 23,\"fields_id\": 2840,\"value\": \"\"},\"2841\": {\"id\": 19,\"fields_id\": 2841,\"value\": \"\"},\"2842\": {\"id\": 22,\"fields_id\": 2842,\"value\": \"\"},\"2844\": {\"id\": 17,\"fields_id\": 2844,\"value\": \"\"},\"2845\": {\"id\": 21,\"fields_id\": 2845,\"value\": \"\"},\"2846\": {\"id\": 13,\"fields_id\": 2846,\"value\": \"Passenger Boarding\"},\"2865\": {\"id\": 20,\"fields_id\": 2865,\"value\": \"\"},\"2975\": {\"id\": 25,\"fields_id\": 2975,\"value\": \"\"},\"2983\": {\"id\": 4,\"fields_id\": 2983,\"value\": \"Yes\"}}}".to_s,
                    6 => "{\"anonymous\": false,\"user_id\": 2232,\"templates_id\": 17,\"completed\": true,\"description\": \"Non English speaker in exit\",\"event_date\": \"2021-11-25T14:21:28.000Z\",\"event_time_zone\": \"Central Time (US & Canada)\",\"submission_fields_attributes\": {\"1540\": {\"id\": 0,\"fields_id\": 1540,\"value\": \"2021-11-25T14:21:55.000Z\"},\"1541\": {\"id\": 1,\"fields_id\": 1541,\"value\": \"\"},\"1542\": {\"id\": 2,\"fields_id\": 1542,\"value\": \"Lead Flight Attendant\"},\"1543\": {\"id\": 3,\"fields_id\": 1543,\"value\": \"\"},\"1544\": {\"id\": 5,\"fields_id\": 1544,\"value\": \"407\"},\"1545\": {\"id\": 6,\"fields_id\": 1545,\"value\": \"KMSP;MSP\"},\"1546\": {\"id\": 9,\"fields_id\": 1546,\"value\": \"N835SY\"},\"1547\": {\"id\": 7,\"fields_id\": 1547,\"value\": \"KSAN;SAN\"},\"1549\": {\"id\": 8,\"fields_id\": 1549,\"value\": \"\"},\"1581\": {\"id\": 27,\"fields_id\": 1581,\"value\": \"\"},\"1582\": {\"id\": 28,\"fields_id\": 1582,\"value\": \"\"},\"1583\": {\"id\": 29,\"fields_id\": 1583,\"value\": \"\"},\"1584\": {\"id\": 30,\"fields_id\": 1584,\"value\": \"\"},\"1585\": {\"id\": 31,\"fields_id\": 1585,\"value\": \"\"},\"1589\": {\"id\": 24,\"fields_id\": 1589,\"value\": \"\"},\"1590\": {\"id\": 26,\"fields_id\": 1590,\"value\": \"\"},\"1591\": {\"id\": 16,\"fields_id\": 1591,\"value\": \"\"},\"1592\": {\"id\": 18,\"fields_id\": 1592,\"value\": \"\"},\"1607\": {\"id\": 14,\"fields_id\": 1607,\"value\": \"Passenger was seated at 14F; during boarding she explained using Google Translate that she left her water bottle in the gate area. 2R tried to talk with her to determine if she could understand English and she could not. We asked the gate agent to move her to 4F where she could have the window seat she paid for but not be in an exit row. FYI, we had only 2 blue bags in the Supply cart in the front.\"},\"1608\": {\"id\": 15,\"fields_id\": 1608,\"value\": \"Perhaps we need a better screening technique for Exit row passengers. Just because there is a window seat open, not everyone is qualified to sit there. \"},\"2837\": {\"id\": 10,\"fields_id\": 2837,\"value\": \"Predeparture/Preflight\"},\"2838\": {\"id\": 11,\"fields_id\": 2838,\"value\": \"\"},\"2839\": {\"id\": 12,\"fields_id\": 2839,\"value\": \"\"},\"2840\": {\"id\": 23,\"fields_id\": 2840,\"value\": \"\"},\"2841\": {\"id\": 19,\"fields_id\": 2841,\"value\": \"\"},\"2842\": {\"id\": 22,\"fields_id\": 2842,\"value\": \"\"},\"2844\": {\"id\": 17,\"fields_id\": 2844,\"value\": \"\"},\"2845\": {\"id\": 21,\"fields_id\": 2845,\"value\": \"\"},\"2846\": {\"id\": 13,\"fields_id\": 2846,\"value\": \"Cabin Preparations\"},\"2865\": {\"id\": 20,\"fields_id\": 2865,\"value\": \"\"},\"2975\": {\"id\": 25,\"fields_id\": 2975,\"value\": \"\"},\"2983\": {\"id\": 4,\"fields_id\": 2983,\"value\": \"No\"}}}".to_s,
                    7 => "{\"anonymous\": false,\"user_id\": 2232,\"templates_id\": 17,\"completed\": true,\"description\": \"No masks, headphones, pretzels\",\"event_date\": \"2021-12-04T09:34:13.000Z\",\"event_time_zone\": \"Central Time (US & Canada)\",\"submission_fields_attributes\": {\"1540\": {\"id\": 0,\"fields_id\": 1540,\"value\": \"\"},\"1541\": {\"id\": 1,\"fields_id\": 1541,\"value\": \"\"},\"1542\": {\"id\": 2,\"fields_id\": 1542,\"value\": \"\"},\"1543\": {\"id\": 3,\"fields_id\": 1543,\"value\": \"\"},\"1544\": {\"id\": 5,\"fields_id\": 1544,\"value\": \"343\"},\"1545\": {\"id\": 6,\"fields_id\": 1545,\"value\": \"KMSP;MSP\"},\"1546\": {\"id\": 9,\"fields_id\": 1546,\"value\": \"N826SY\"},\"1547\": {\"id\": 7,\"fields_id\": 1547,\"value\": \"\"},\"1549\": {\"id\": 8,\"fields_id\": 1549,\"value\": \"KMCO;MCO\"},\"1581\": {\"id\": 27,\"fields_id\": 1581,\"value\": \"\"},\"1582\": {\"id\": 28,\"fields_id\": 1582,\"value\": \"\"},\"1583\": {\"id\": 29,\"fields_id\": 1583,\"value\": \"\"},\"1584\": {\"id\": 30,\"fields_id\": 1584,\"value\": \"\"},\"1585\": {\"id\": 31,\"fields_id\": 1585,\"value\": \"\"},\"1589\": {\"id\": 24,\"fields_id\": 1589,\"value\": \"\"},\"1590\": {\"id\": 26,\"fields_id\": 1590,\"value\": \"\"},\"1591\": {\"id\": 16,\"fields_id\": 1591,\"value\": \"\"},\"1592\": {\"id\": 18,\"fields_id\": 1592,\"value\": \"\"},\"1607\": {\"id\": 14,\"fields_id\": 1607,\"value\": \"Many kids 2-3 yrs old came on without masks and parents were skeptical their kids would wear them. Several passengers had very thin gators which are not allowed but we had no masks in the service cart up front. passenger in 1c had two kids scared to fly. They were listening to loud music games during boarding and had no headphones. Father was shocked that headphones are required and was frantic his kids would not be able to calm down. We had no headphones to sell. Also, we do not have enough small Dots bags for premium seating for both legs of the flight. \"},\"1608\": {\"id\": 15,\"fields_id\": 1608,\"value\": \"Gate agents could do a better job of monitoring masks as people board. Thin gators are not allowed per the manual and gate agents never screen for this. Also kids 2 and up must have masks but are not told this until they get on the plane. We must have headphones to sell if we are requiring headphones and advertising them for sale. We must have masks in the front galley to give to passengers when needed.\"},\"2837\": {\"id\": 10,\"fields_id\": 2837,\"value\": \"Predeparture/Preflight\"},\"2838\": {\"id\": 11,\"fields_id\": 2838,\"value\": \"\"},\"2839\": {\"id\": 12,\"fields_id\": 2839,\"value\": \"100\"},\"2840\": {\"id\": 23,\"fields_id\": 2840,\"value\": \"\"},\"2841\": {\"id\": 19,\"fields_id\": 2841,\"value\": \"\"},\"2842\": {\"id\": 22,\"fields_id\": 2842,\"value\": \"\"},\"2844\": {\"id\": 17,\"fields_id\": 2844,\"value\": \"\"},\"2845\": {\"id\": 21,\"fields_id\": 2845,\"value\": \"\"},\"2846\": {\"id\": 13,\"fields_id\": 2846,\"value\": \"Passenger Boarding\"},\"2865\": {\"id\": 20,\"fields_id\": 2865,\"value\": \"\"},\"2975\": {\"id\": 25,\"fields_id\": 2975,\"value\": \"\"},\"2983\": {\"id\": 4,\"fields_id\": 2983,\"value\": \"No\"}}}".to_s}


      begin
        (1..7).each do |key|
          h = JSON.parse(json_hash[key])

          if h["submission_fields_attributes"].present?
            h["submission_fields_attributes"].each do |k,v|
              v.delete("id")
            end
          end

          @logger.info "[INFO][CREATE_SUBMISSIONS_TASK]: #{key}"
          @logger.info "[INFO][CREATE_SUBMISSIONS_TASK]: #{h.to_s}"
          @logger.info "\n\n"
          rep = Submission.new(h)
          rep.save
          Submission.find(rep.id).make_report
        end
      rescue => err
        @logger.info "[ERROR][CREATE_SUBMISSIONS_TASK]: #{err.message}"
      end
    rescue => error
      @logger.info "[ERROR][CREATE_SUBMISSIONS_TASK]: #{error.message}"
    end
  end


  task :get_query_fields_list => [:environment] do |t|
    begin
      @logger = Logger.new("log/query_fields.log")
      object_arr = ['Submission', 'Record', 'Report', 'Meeting', 'CorrectiveAction', 'Audit', 'Inspection', 'Evaluation', 'Investigation', 'Finding', 'SmsAction', 'Recommendation', 'Sra', 'Hazard', 'RiskControl', 'SafetyPlan', 'SrmMeeting']

      object_arr.each do |obj|
        fields = Object.const_get(obj).get_meta_fields('show', 'index', 'invisible', 'query')

        @logger.info "[OBJECT]: #{obj}\n"
        @logger.info "#{fields.map{|f| f[:field]}.split('\n')}"
        @logger.info "#{fields.map{|f| f[:type]}.split('\n')}"
        @logger.info "\n\n"
      end

    rescue => error
      @logger.info "[ERROR][GET_QUERY_FIELDS_TASK]: #{error.message}"
    end
  end

end

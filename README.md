# VampiresVsZombies

A fictitious world consists of only vampires and zombies. A large portion of the vampire population has Vitamin D deficiency (ICD-9 diagnosis code 268) and/or skin cancer (ICD-9 diagnosis code 172.9).  Vampires require varying amounts of blood transfusion throughout the plan year (CPT procedure code 36430).  Health care is costly for vampires.

Zombies have limited medical needs.  Occasionally, a zombie will be encountered with the need for limb amputation (ICD-9 diagnosis code 897).  Otherwise, it a can be assumed that zombies do not require health care.

A single health care premium of $10,000 is charged for both vampires and zombies.  This allows both populations to afford health coverage.  In order to prevent health insurers from selecting only zombies as members, an algorithm is used to assign a score and compensate insurers who enroll the more expensive vampire population.  For example, if health insurer A covers a vampire-rich population of 500 members with a total score of 600 and health insurer B covers a zombie-rich population of 500 members with a total score of 400, then $10,000 x (600 – 400) = $2,000,000 is redistributed from health insurer B to health insurer A.

The following table outlines the logic for assigning a score for vampires by using the current algorithm:


Vampires
                                   Base Score for all Vampires
Starting score for a vampire regardless of diagnoses present                   1.5

Diagnosis Code          |          Diagnosis Description               |          Score

                          Vitamin D Deficiency Related Conditions
268.9            |           Unspecified vitamin D deficiency           |           2

                               Skin Cancer Related Conditions
172.9             |          Melanoma of skin, site unspecified         |           5

                                      Additional Effects
268.9 and 172.9      |          Vitamin D deficiency and Melanoma        |          3
 
       	
Examples:
    • A vampire displaying no diagnoses has a base score of 1.5
    
    • The model is additive for single conditions i.e. a vampire displaying vitamin D deficiency without Melanoma
    present has a total score of 1.5 (base) + 2 (vitamin D deficiency) = 3.5.  A vampire displaying Melanoma
    without vitamin D deficiency present has a total score of 1.5 (base) +5 (Melanoma) = 6.5.
    
    • There is an additional effect for co-morbid vampires displaying both vitamin D deficiency and Melanoma.  
    These vampires have a score of 1.5 (base) + 2 (vitamin D deficiency) + 5 (Melanoma) + 3 (additional effect) = 11.5
    


The following table outlines the logic for assigning a score for zombies by using the current algorithm:

Zombies
                                        Base Score for all Zombies
Starting score for zombies regardless of diagnoses present                         1

Diagnosis Code                |            Diagnosis Description          |        Score
                                            Amputation of Leg
897.2                        |             Unilateral amputation           |          2
897.6                         |             Bilateral amputation                     3

                                          Overlapping Diagnosis
897.2 and 897.6                  Only the bilateral amputation is scored      |     3
 
Examples:
    - A zombie without any diagnoses present has a score of 1 (base score)
    
    - A zombie with unilateral amputation present and bilateral amputation is not present has a total score of 1
    (base) + 2 (unilateral amputation) = 3

    - A zombie with bilateral amputation present and unilateral amputation is not present has a total score
    of 1 (base) + 3 (bilateral amputation) = 4
    
    - A zombie with both bilateral and unilateral amputation present still has the same score of 4 as 
    bilateral amputation since zombies can only have two legs
    

There are members and conditions data files. The members file ('members.csv') contains a unique member identifier (called ID) and a binary indicator for whether or not the member is a vampire (called v_flag).  A 1 in this field indicates that the member is a vampire.  If the member is not a vampire, then they are a zombie.  Additionally, the member file contains the actual health care cost for the previous year (called act_cost).

The conditions file ('conditions.csv') contains the identifier from the member file (called ID) and a diagnosis present from the previous year’s claims (called prev_dx).

QUESTIONS:
    1. Use the two data files to compute the scores under the current algorithm. Provide the comma separated value file titled “current_scores.csv” that contains the unique member identifier (called ID) and the calculated score as defined above (called cur_score) and the programming code file that was used to calculate the score.

    2. Health insurers are concerned that the current algorithm does not adequately compensate them for the additional cost of covering vampires. What is the calculated error between actual claims (the act_cost field in the members file) and the expected claims (i.e. $10,000 x score)?  State the measure of error that you chose. Why did you choose it to measure this particular type of data? Provide the calculated errors on the data as well as the code used to calculate the value of the error metric on each of the vampires and zombies.

    3. Explain the interpretation of the measure of error. Say whether or not the health insurers are rightfully concerned about the current algorithm’s accuracy.

Insurers in the system consistently pay less than expected: by a mean of about $20,000

    4. Improve the algorithm’s accuracy relative to the measure of error that you chose above. Build an algorithm for actual cost that performs better under that metric than the current algorithm. Describe the approach that you decided to take and why. Provide a comma separated value file that contains the unique member identifier (called ID) and the new scores calculated using your improved algorithm (called new_score). Send the programming code file that was used to calculate the new scores.




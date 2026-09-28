#!/bin/bash
# ================================================================
#  SOCIALKARO - Social Media Marketing Service System (Simple)
#
#  No database is used. Everything is kept in 3 text files:
#    data.txt        -> customer details   username:name:mobile:business
#    credentials.txt -> login details      username:password
#    receipt.txt     -> receipts           receipt_no:username:date:service:qty:amount:gst:total:mode
# ================================================================

DATA=data.txt
CRED=credentials.txt
RECEIPT=receipt.txt

# ---------- create the files if they are missing ----------
if [ ! -f $DATA ]
then
    echo -n > $DATA
fi
if [ ! -f $CRED ]
then
    echo -n > $CRED
fi
if [ ! -f $RECEIPT ]
then
    echo -n > $RECEIPT
fi
chmod 600 $CRED              # only the owner can read/write passwords

choice=0
while [ "$choice" != "3" ]
do
    echo
    echo "=============================================="
    echo "       SOCIALKARO - MARKETING SERVICES        "
    echo "=============================================="
    echo "Date : $(date '+%d-%m-%Y  %I:%M %p')"
    echo "1. New Customer (Register)"
    echo "2. Login"
    echo "3. Exit"
    printf "Enter your choice : "
    read choice

    case $choice in

    1)  # ======================= REGISTER =======================
        echo
        echo "--------------- NEW CUSTOMER ---------------"

        user=""
        while [ -z "$user" ]
        do
            printf "Choose username (3-10 small letters/digits) : "
            read user
            if [ $(echo "$user" | grep -c -x "[a-z0-9]\{3,10\}") -eq 0 ]
            then
                echo "Invalid username."
                user=""
            elif [ $(grep -c "^$user:" $CRED) -gt 0 ]
            then
                echo "Username already exists. Try another."
                user=""
            fi
        done

        name=""
        while [ -z "$name" ]
        do
            printf "Full name : "
            read name
            if [ $(echo "$name" | grep -c -x "[A-Za-z ]\{2,30\}") -eq 0 ]
            then
                echo "Use letters and spaces only."
                name=""
            fi
        done

        mobile=""
        while [ -z "$mobile" ]
        do
            printf "Mobile number (10 digits) : "
            read mobile
            if [ $(echo "$mobile" | grep -c -x "[0-9]\{10\}") -eq 0 ]
            then
                echo "Mobile number must be exactly 10 digits."
                mobile=""
            elif [ $(grep -c ":$mobile:" $DATA) -gt 0 ]
            then
                echo "This mobile number is already registered."
                mobile=""
            fi
        done

        business=""
        while [ -z "$business" ]
        do
            printf "Business name : "
            read business
            if [ $(echo "$business" | grep -c -x "[A-Za-z0-9 ]\{2,30\}") -eq 0 ]
            then
                echo "Use letters, digits and spaces only."
                business=""
            fi
        done

        pass=""
        while [ -z "$pass" ]
        do
            printf "Choose password (min 4 letters/digits) : "
            stty -echo                  # hide the password while typing
            read pass
            stty echo
            echo
            if [ $(echo "$pass" | grep -c -x "[A-Za-z0-9]\{4,\}") -eq 0 ]
            then
                echo "Password must be at least 4 letters/digits."
                pass=""
            fi
        done

        echo "$user:$name:$mobile:$business" >> $DATA
        echo "$user:$pass" >> $CRED
        echo "Registration successful! You can login now."
        ;;

    2)  # ======================== LOGIN ========================
        echo
        echo "--------------- CUSTOMER LOGIN ---------------"
        tries=3
        login=no
        while [ $tries -gt 0 ]
        do
            printf "Username : "
            read user
            printf "Password : "
            stty -echo
            read pass
            stty echo
            echo
            # check the typed details against credentials.txt
            if [ $(grep -c -x -F "$user:$pass" $CRED) -eq 1 ]
            then
                login=yes
                tries=0
            else
                tries=$(echo "$tries - 1" | bc)
                echo "Wrong username or password. Attempts left : $tries"
            fi
        done

        if [ $login = no ]
        then
            echo "Too many wrong attempts. Access denied."
            continue
        fi

        # read this customer's details from data.txt
        # (turn every : into a new line, then pick the line we need)
        line=$(grep "^$user:" $DATA)
        name=$(echo "$line" | sed 's/:/\n/g' | head -2 | tail -1)
        mobile=$(echo "$line" | sed 's/:/\n/g' | head -3 | tail -1)
        business=$(echo "$line" | sed 's/:/\n/g' | tail -1)
        echo "Login successful. Welcome, $name!"

        opt=0
        while [ "$opt" != "5" ]
        do
            echo
            echo "--------------- CUSTOMER MENU ---------------"
            echo "1. My Details"
            echo "2. Place Order & Pay"
            echo "3. My Receipts"
            echo "4. Change Password"
            echo "5. Logout"
            printf "Enter your choice : "
            read opt

            case $opt in

            1)  # ---------- MY DETAILS ----------
                echo
                echo "Username : $user"
                echo "Name     : $name"
                echo "Mobile   : $mobile"
                echo "Business : $business"
                ;;

            2)  # ---------- PLACE ORDER ----------
                echo
                echo "--------------- OUR SERVICES ---------------"
                echo "1. Social Media Account Setup      Rs.  1500"
                echo "2. Custom Post Design (per post)   Rs.   300"
                echo "3. Reel / Video Editing            Rs.   800"
                echo "4. Instagram Ad Campaign           Rs.  8000"
                echo "5. Monthly Management Package      Rs. 15000"
                printf "Select service (1-5) : "
                read sid
                case $sid in
                1) service="Account Setup";   price=1500 ;;
                2) service="Post Design";     price=300 ;;
                3) service="Reel Editing";    price=800 ;;
                4) service="Ad Campaign";     price=8000 ;;
                5) service="Monthly Package"; price=15000 ;;
                *) echo "Invalid service number."
                   continue ;;
                esac

                printf "Quantity : "
                read qty
                if [ $(echo "$qty" | grep -c -x "[1-9][0-9]\{0,2\}") -eq 0 ]
                then
                    echo "Quantity must be a number from 1 to 999."
                    continue
                fi

                amount=$(echo "$price * $qty" | bc)
                gst=$(echo "$amount * 18 / 100" | bc)
                total=$(echo "$amount + $gst" | bc)
                echo "Amount    : Rs. $amount"
                echo "GST (18%) : Rs. $gst"
                echo "Total     : Rs. $total"

                echo "Payment mode : 1. Cash   2. UPI   3. Card   4. Cancel"
                printf "Select : "
                read pm
                case $pm in
                1) mode=Cash ;;
                2) mode=UPI ;;
                3) mode=Card ;;
                *) echo "Order cancelled."
                   continue ;;
                esac

                # next receipt number = number of lines in receipt.txt + 1001
                rno=R$(echo "$(grep -c "" $RECEIPT) + 1001" | bc)
                rdate=$(date +%d-%m-%Y)
                echo "$rno:$user:$rdate:$service:$qty:$amount:$gst:$total:$mode" >> $RECEIPT

                echo
                echo "=============================================="
                echo "             SOCIALKARO - RECEIPT             "
                echo "=============================================="
                echo "Receipt No : $rno"
                echo "Date       : $rdate"
                echo "Customer   : $name ($mobile)"
                echo "Business   : $business"
                echo "----------------------------------------------"
                echo "Service    : $service"
                echo "Price      : Rs. $price x $qty = Rs. $amount"
                echo "GST (18%)  : Rs. $gst"
                echo "TOTAL PAID : Rs. $total"
                echo "Paid by    : $mode"
                echo "=============================================="
                echo "Receipt saved in $RECEIPT"
                ;;

            3)  # ---------- MY RECEIPTS ----------
                echo
                count=$(grep -c "^R[0-9]*:$user:" $RECEIPT)
                if [ $count -eq 0 ]
                then
                    echo "No receipts found."
                    continue
                fi
                echo "RECEIPT | USER | DATE | SERVICE | QTY | AMOUNT | GST | TOTAL | MODE"
                grep "^R[0-9]*:$user:" $RECEIPT | sed 's/:/ | /g'

                # add up the TOTAL column (last-but-one field) with a for loop
                spent=0
                for t in $(grep "^R[0-9]*:$user:" $RECEIPT | sed 's/:[A-Za-z]*$//' | sed 's/.*://')
                do
                    spent=$(echo "$spent + $t" | bc)
                done
                echo "Total receipts : $count      Total spent : Rs. $spent"
                ;;

            4)  # ---------- CHANGE PASSWORD ----------
                printf "Old password : "
                stty -echo
                read old
                stty echo
                echo
                if [ $(grep -c -x -F "$user:$old" $CRED) -eq 0 ]
                then
                    echo "Wrong password."
                    continue
                fi
                printf "New password (min 4 letters/digits) : "
                stty -echo
                read new
                stty echo
                echo
                if [ $(echo "$new" | grep -c -x "[A-Za-z0-9]\{4,\}") -eq 0 ]
                then
                    echo "Password must be at least 4 letters/digits."
                    continue
                fi
                # replace this user's line in credentials.txt
                sed "s/^$user:.*/$user:$new/" $CRED > temp.txt
                mv temp.txt $CRED
                chmod 600 $CRED
                echo "Password changed successfully."
                ;;

            5)  echo "Logged out. Goodbye, $name!" ;;

            *)  echo "Invalid choice. Enter 1 to 5." ;;
            esac
        done
        ;;

    3)  echo "Thank you for using SOCIALKARO!" ;;

    *)  echo "Invalid choice. Enter 1 to 3." ;;
    esac
done

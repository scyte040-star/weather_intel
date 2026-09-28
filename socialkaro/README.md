# SOCIALKARO – Simple Version

A small Bash shell script for ordering social media marketing services.
There is **no database**. Everything is stored in **3 text files**, and when a
customer types their details the script checks them against these files
using `grep`.

## The 3 files

| File | What it stores | Format (one line per record) | Example |
|---|---|---|---|
| `data.txt` | Customer details | `username:name:mobile:business` | `meera:Meera Kulkarni:9822334455:TrendWave Apparel` |
| `credentials.txt` | Login details | `username:password` | `meera:meera123` |
| `receipt.txt` | Receipts | `receipt_no:username:date:service:qty:amount:gst:total:mode` | `R1001:meera:13-09-2026:Post Design:3:900:162:1062:UPI` |

Fields are separated by `:`, the same way Linux stores users in `/etc/passwd`.
If a file is missing, the script creates it empty.

## How to run

```bash
cd socialkaro
chmod +x socialkaro.sh
./socialkaro.sh
```

Demo logins already in the files: `meera` / `meera123` and `rahul` / `rahul123`.

## Working flow

```
Main Menu ── 1. Register ──> checks data.txt and credentials.txt for duplicates
          │                  saves details to data.txt and password to credentials.txt
          ├─ 2. Login ─────> checks username:password in credentials.txt (3 attempts)
          │                  reads the customer's details from data.txt
          │     ├─ 1. My Details
          │     ├─ 2. Place Order & Pay ─> calculates amount + 18% GST, adds a line to receipt.txt
          │     ├─ 3. My Receipts ──────> finds the customer's lines in receipt.txt, adds up the totals
          │     ├─ 4. Change Password ──> rewrites that line in credentials.txt using sed
          │     └─ 5. Logout
          └─ 3. Exit
```

## How the file check works

| Check | Command used |
|---|---|
| Login is correct? | `grep -c -x -F "$user:$pass" credentials.txt` (whole line must match) |
| Username already taken? | `grep -c "^$user:" credentials.txt` |
| Mobile already registered? | `grep -c ":$mobile:" data.txt` |
| Get the customer's name | `grep "^$user:" data.txt \| sed 's/:/\n/g' \| head -2 \| tail -1` |
| Mobile is 10 digits? | `echo "$mobile" \| grep -c -x "[0-9]\{10\}"` |
| Show only my receipts | `grep "^R[0-9]*:$user:" receipt.txt \| sed 's/:/ \| /g'` |
| Change password | `sed "s/^$user:.*/$user:$new/" credentials.txt > temp.txt` then `mv temp.txt credentials.txt` |

## Syllabus topics used

| Unit | Topic | Where it is used |
|---|---|---|
| III 3.1 | `echo`, `printf` | Menus, receipts, prompts |
| III 3.1 | `date` | Date on the main menu and on each receipt |
| III 3.1 | `stty` | `stty -echo` hides the password while typing |
| III 3.1 | `bc` | Amount, GST, total, attempts left, receipt number |
| III 3.1 | `chmod`, file permissions | `chmod 600 credentials.txt`: only the owner can read passwords |
| III 3.1 | `mv`, `head`, `tail` | Saving the new password file, picking fields out of a line |
| III 3.2 | Shell variables, `read` | All customer input |
| III 3.2 | `if-else` / `elif` | Input checks, login check |
| III 3.2 | `case` (switch) | Main menu, customer menu, service price, payment mode |
| III 3.2 | `while`, `for` | Menus and retry loops, adding up the totals |
| III 3.2 | Pipes `\|` | `grep ... \| sed ... \| head ... \| tail ...` |
| III 3.3 | `grep`, `sed` | Searching and editing the 3 files |

## Viewing the files from the terminal

```bash
cat data.txt                # all customers
more receipt.txt            # receipts, one screen at a time
grep meera receipt.txt      # one customer's receipts
tail -3 receipt.txt         # last 3 receipts
ls -l *.txt                 # check the file permissions
```

To save a full run of the program as output for the project report:

```bash
script output.txt           # start recording
./socialkaro.sh             # use the program
exit                        # stop recording; everything is in output.txt
```

## Notes

- **Git Bash on Windows** does not include `bc`. Run the script on Linux or WSL
  (Ubuntu), where `bc` is available (`sudo apt install bc` if missing).
- If you press Ctrl+C while typing a password and the terminal stops showing
  what you type, run `stty echo`.
- Passwords are stored as plain text. This is fine for a class project, but a
  real system would not store them this way.

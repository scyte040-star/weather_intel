# Social Media Marketing Agency System (Python)

A simple Data Structure and Algorithm project in Python. The agency's clients are
kept in a **singly linked list**, saved in a **file**, and the staff login is
checked from a file.

## Files

| File | What it stores | Format (one line per record) |
|---|---|---|
| `agency.py` | The program | – |
| `clients.txt` | Client records | `name,phone,platform,service,budget` |
| `login.txt` | Staff logins | `username,password` |
| `SMM_Agency_Project_Report.pdf` | Project report | Introduction, SWOT, Learning from the case, code, output |

## Run

```bash
cd smm_agency
python3 agency.py
```

Demo logins: `admin` / `admin123` and `manager` / `smm2026`.

## Menu

1. Add New Client – inserts a node at the end of the linked list
2. Display All Clients – traverses the list, shows total monthly budget
3. Search Client – linear search by name or phone number
4. Update Client Package – changes service and budget
5. Delete Client – unlinks the node from the list
6. Exit

`clients.txt` is saved after every add, update and delete.

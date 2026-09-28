# SOCIAL MEDIA MARKETING AGENCY SYSTEM
# Data Structure used : Singly Linked List
# Files used          : clients.txt -> client records
#                                      (name,phone,platform,service,budget)
#                       login.txt   -> staff login details (username,password)

CLIENT_FILE = "clients.txt"
LOGIN_FILE = "login.txt"

PLATFORMS = ["Instagram", "Facebook", "YouTube", "LinkedIn"]
SERVICES = ["Post Design", "Reels Editing", "Ad Campaign", "Account Management"]


class Client:
    # one node of the linked list = one client of the agency
    def __init__(self, name, phone, platform, service, budget):
        self.name = name
        self.phone = phone
        self.platform = platform
        self.service = service
        self.budget = budget
        self.next = None


class AgencyList:
    def __init__(self):
        self.head = None

    # insert a new client node at the end of the list
    def add_client(self, name, phone, platform, service, budget):
        new_node = Client(name, phone, platform, service, budget)
        if self.head is None:
            self.head = new_node
            return
        current = self.head
        while current.next is not None:
            current = current.next
        current.next = new_node

    # visit every node from head to the end and print it
    def display_clients(self):
        if self.head is None:
            print("--- No clients available ---")
            return
        print(f"{'NO':<4}{'NAME':<19}{'PHONE':<12}"
              f"{'PLATFORM':<11}{'SERVICE':<20}{'BUDGET':>8}")
        print("-" * 74)
        count = 0
        total = 0
        current = self.head
        while current is not None:
            count = count + 1
            total = total + current.budget
            print(f"{count:<4}{current.name[:18]:<19}{current.phone:<12}"
                  f"{current.platform:<11}{current.service:<20}"
                  f"{current.budget:>8}")
            current = current.next
        print("-" * 74)
        print("Total Clients :", count, "     Total Monthly Budget : Rs.", total)

    # linear search by name or phone number, returns the node or None
    def find_client(self, key):
        current = self.head
        while current is not None:
            if current.name.lower() == key.lower() or current.phone == key:
                return current
            current = current.next
        return None

    def search_client(self, key):
        node = self.find_client(key)
        if node is None:
            print("Sorry!", key, "is not available in the client list")
        else:
            print("Client Found!")
            print("Name     :", node.name)
            print("Phone    :", node.phone)
            print("Platform :", node.platform)
            print("Service  :", node.service)
            print("Budget   : Rs.", node.budget)

    def update_client(self, key, new_service, new_budget):
        node = self.find_client(key)
        if node is None:
            print("Sorry!", key, "is not available in the client list")
            return False
        node.service = new_service
        node.budget = new_budget
        print(node.name, "updated successfully!")
        return True

    # remove a node by changing the link of the previous node
    def delete_client(self, key):
        if self.head is None:
            print("--- No clients available ---")
            return False
        if self.head.name.lower() == key.lower() or self.head.phone == key:
            print(self.head.name, "deleted successfully!")
            self.head = self.head.next
            return True
        previous = self.head
        current = self.head.next
        while current is not None:
            if current.name.lower() == key.lower() or current.phone == key:
                previous.next = current.next
                print(current.name, "deleted successfully!")
                return True
            previous = current
            current = current.next
        print("Sorry!", key, "is not available in the client list")
        return False

    # write every node to the file, one client per line
    def save_to_file(self):
        with open(CLIENT_FILE, "w") as file:
            current = self.head
            while current is not None:
                file.write(f"{current.name},{current.phone},{current.platform},"
                           f"{current.service},{current.budget}\n")
                current = current.next

    # read the file and build the linked list
    def load_from_file(self):
        try:
            with open(CLIENT_FILE, "r") as file:
                for line in file:
                    parts = line.strip().split(",")
                    if len(parts) == 5:
                        self.add_client(parts[0], parts[1], parts[2],
                                        parts[3], int(parts[4]))
        except FileNotFoundError:
            print("(clients.txt not found - starting with an empty list)")


# check the username and password against login.txt
def check_login(username, password):
    try:
        with open(LOGIN_FILE, "r") as file:
            for line in file:
                parts = line.strip().split(",")
                if len(parts) == 2:
                    if parts[0] == username and parts[1] == password:
                        return True
    except FileNotFoundError:
        print("login.txt not found!")
    return False


def choose(title, options):
    for i in range(len(options)):
        print(f"  {i + 1}. {options[i]}")
    while True:
        pick = input(title)
        if pick.isdigit() and 1 <= int(pick) <= len(options):
            return options[int(pick) - 1]
        print("Please enter a number from 1 to", len(options))


def ask_budget():
    while True:
        budget = input("Monthly Budget (Rs.) : ")
        if budget.isdigit() and int(budget) > 0:
            return int(budget)
        print("Budget must be a number greater than 0")


# ------------------------------ MAIN PROGRAM ------------------------------
print("=" * 50)
print("     SOCIAL MEDIA MARKETING AGENCY SYSTEM")
print("=" * 50)
user_name = input("Hello! Welcome --- What's your name : ")

logged_in = False
attempts = 3
while attempts > 0 and not logged_in:
    username = input(user_name + ", please enter Username : ")
    password = input(user_name + ", please enter Password : ")
    if check_login(username, password):
        logged_in = True
    else:
        attempts = attempts - 1
        print("<---- Incorrect Username or Password ---->")
        print("Attempts left :", attempts)

if not logged_in:
    print("Access denied. Please contact the agency admin.")
else:
    print("\n---- Login Successful ----\n")
    agency = AgencyList()
    agency.load_from_file()
    agency.display_clients()

    choice = ""
    while choice != "6":
        print("\n------------- MENU -------------")
        print(" 1. Add New Client")
        print(" 2. Display All Clients")
        print(" 3. Search Client")
        print(" 4. Update Client Package")
        print(" 5. Delete Client")
        print(" 6. Exit")
        choice = input("Enter your choice : ")

        if choice == "1":
            name = input("Client / Business Name : ").replace(",", " ").strip()
            if name == "":
                print("Name cannot be empty")
            elif agency.find_client(name) is not None:
                print("Client", name, "already exists")
            else:
                phone = input("Phone Number (10 digits) : ")
                while not (phone.isdigit() and len(phone) == 10):
                    phone = input("Invalid! Enter 10 digit Phone Number : ")
                print("Select Platform :")
                platform = choose("Platform number : ", PLATFORMS)
                print("Select Service :")
                service = choose("Service number : ", SERVICES)
                budget = ask_budget()
                agency.add_client(name, phone, platform, service, budget)
                agency.save_to_file()
                print("<---- Client stored successfully in clients.txt ---->")

        elif choice == "2":
            print("---------------- ALL CLIENTS ----------------")
            agency.display_clients()

        elif choice == "3":
            key = input("Enter Client Name or Phone Number to search : ")
            agency.search_client(key)

        elif choice == "4":
            key = input("Enter Client Name or Phone Number to update : ")
            if agency.find_client(key) is None:
                print("Sorry!", key, "is not available in the client list")
            else:
                print("Select New Service :")
                service = choose("Service number : ", SERVICES)
                budget = ask_budget()
                if agency.update_client(key, service, budget):
                    agency.save_to_file()

        elif choice == "5":
            key = input("Enter Client Name or Phone Number to delete : ")
            if agency.delete_client(key):
                agency.save_to_file()

        elif choice == "6":
            print("----- THANK YOU FOR USING THE AGENCY SYSTEM -----")

        else:
            print("Please enter a valid option (1-6)")

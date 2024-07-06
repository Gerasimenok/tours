///////
#include <iostream>
#include <iomanip>
#include <windows.h>
#include <fstream>
#include <string>
#include <conio.h>
#include <codecvt>

using namespace std;

struct User {
    string username;
    string password;
};

void ShowUsers();
void printFoundTours(wstring** lines, int lineCount);
void DeleteChoosenTour();
void printCentered(const string& text, int numLines);
void Findtours(wstring**& lines, int& lineCount);
void split(const wstring& input, wstring& storedCityOfDeparture, wstring& storedCountryOfArrival,
    wstring& storedResortCity, wstring& storedStartDate, wstring& storedEndDate, wstring& storedMaxCost);
bool isDateInRange(wstring startDate, wstring storedStartDate, wstring storedEndDate);
void FindToDeletIrrelevant();
wstring splitEndDate(const wstring line);
void Deleting(const wstring& lineToDelete, const string filename);
wstring stringToWstring(const string& str);
string wstringToString(const wstring& wstr);
void DeleteChoosenUser(int role, string userlogin);
void changeAccountData(const string filename, const string userlogin, const string userpassword, int field, User& currentUser);
void addNewData(const string filename, string userloginandpassword);
string getFieldsOfNewUser();
void addNewTour(const string filename, wstring addedline);
wstring getFieldsOfNewTour();
void addFoundToursInArray(wstring**& lines, int& lineCount, const wstring& line);
void shakerSort(wstring**& lines, int lineCount, int index, int cresing);
void ifSort(wstring** lines, int lineCount);


bool isUsernameUnique(const string& filename, const string& username) {
    ifstream infile(filename);
    if (!infile.is_open()) {
        cerr << "Ошибка открытия файла!" << endl;
        exit(1);
    }

    string storedUsername, storedPassword;
    while (infile >> storedUsername >> storedPassword) {
        if (storedUsername == username) {
            return false; 
        }
    }
    return true;
}

// Функция проверки логина и пароля на содержание пробелов
/*bool CorrectLogin(const string& login) {
    size_t pos = login.find(" ");
    if (pos != string::npos) {
        cout << "Логин не может содержать пробелы. Введите еще раз: ";
        return false;
    }
    else {
        return true;
    }
}
*/

bool registerUser(const string& filename, User& currentUserLogin) {//сделать центрирование текста
    ofstream file(filename, ios::app);
    if (!file.is_open()) {
        cerr << "Ошибка открытия файла!" << endl;
        exit(1);
    }

    cout << "Введите логин: ";
    string username;
    cin >> username;


    while (!isUsernameUnique(filename, username)) {
        cout << "Пользователь с таким логином уже существует. Пожалуйста, выберите другой логин." << endl;
        cout << "Введите логин: ";
        cin >> username;
    }

    cout << "Введите пароль: ";
    string password;
    cin >> password;


    file << username << " " << password << endl;
    cout << "Пользователь зарегистрирован. Теперь войдите в систему." << endl; //переделать чтоб зарег пользователь проходил авторизацию
    currentUserLogin.username = username;
    currentUserLogin.password = password;
    file.close();
    return true;
}

bool loginUser(const string& filename, User& currentUserLogin) {
    ifstream infile(filename);
    if (!infile.is_open()) {
        cerr << "Ошибка открытия файла!" << endl;
        exit(1);
    }

    int attempts = 3;
    bool found = false;

    while (attempts > 0 && !found) {
        string username, password;
        cout << "Введите логин: ";
        cin >> username;
        cout << "Введите пароль: ";
        cin >> password;

        string storedUsername, storedPassword;

        while (infile >> storedUsername >> storedPassword) {
            if (storedUsername == username && storedPassword == password) {
                found = true;
                currentUserLogin.username = username; 
                currentUserLogin.password = password;
                break;
            }
        }

        if (found) {
            cout << "Вы успешно вошли в систему." << endl;
            Sleep(700);
            return true;
        }
        else {
            attempts--;
            if (attempts > 0) {
                cout << "Неправильный логин или пароль. Попробуйте еще раз." << endl;
                Sleep(700);
            }
        }
        infile.clear();
        infile.seekg(0, ios::beg);
    }

    cout << "Вы исчерпали все попытки входа в систему." << endl;
    Sleep(700);
    return false;
}


// Функция для входа администратора
bool adminLogin(const string& adminPasswordFile) {
    ifstream infile(adminPasswordFile);
    if (!infile.is_open()) {
        cerr << "Ошибка открытия файла!" << endl;
        exit(1);
    }

    int attempts = 3;
    bool found = false;

    while (attempts > 0 && !found) {
        string adminPassword;
        printCentered("Введите пароль администратора: ", 1);
        cin >> adminPassword;

        string storedPassword;
        infile >> storedPassword;

        if (adminPassword == storedPassword) {
            printCentered("Вы успешно вошли как администратор.", 1);
            found = true;
            Sleep(700);
        }
        else {
            attempts--;
            if (attempts > 0) {
                printCentered("Неправильный пароль администратора. Попробуйте еще раз.", 1);
                Sleep(700);
            }
        }

        infile.clear();
        infile.seekg(0, ios::beg); // cброс в начало файла
    }

    if (attempts == 0) {
        printCentered("Вы исчерпали все попытки входа в систему.", 1);
    }
    infile.close();
    return found;
}

void printCentered(const string& text, int numLines)
{
    system("cls");
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);

    int consoleWidth = csbi.srWindow.Right - csbi.srWindow.Left + 1;
    int consoleHeight = csbi.srWindow.Bottom - csbi.srWindow.Top + 1;

    int totalTextLines = numLines;

    int posY = (consoleHeight - totalTextLines) / 2;

    int startPos = 0;
    int posX = 0;
    for (int i = 0; i < totalTextLines; i++) {
        string line;
        int found = text.find('\n', startPos);
        if (found != string::npos) {
            line = text.substr(startPos, found - startPos);
            startPos = found + 1;
        }
        else {
            line = text.substr(startPos);
        }

        if (i == 0) {
            posX = (consoleWidth - line.length()) / 2;
        }

        COORD cursorPos = { posX, posY + i };
        SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cursorPos);
        cout << line;
    }
}



int main() {
    setlocale(LC_ALL, "Ru");
    SetConsoleCP(1251);
    SetConsoleOutputCP(1251);
    ShowWindow(GetConsoleWindow(), SW_MAXIMIZE);


    string MAINMENUFORINTER = "1.Регистрация\n2.Вход\n3.Вход для администратора\nВыберите действие: ";

    printCentered(MAINMENUFORINTER, 4);

    User currentUserlogin;
    bool entered = false;
    int choice;

    wstring** lines = nullptr;
    int lineCount = 0;

    cin >> choice;
    system("cls");
    switch (choice) {
    case 1:
        registerUser("users.txt", currentUserlogin);
    case 2:
        entered = loginUser("users.txt", currentUserlogin);
        break;
    case 3:
        entered = adminLogin("admin.txt");
        break;
    default:
        printCentered("Неправильный выбор. Вы вышли из системы.", 1);
        break;
    }

    if (!entered) {
        exit(0);
    }

    if (choice == 1 || choice == 2) {//при 2 в майн не возврат после входа возврвт в функцию входа
        system("cls");
        printCentered("1.Найти тур\n2.Просмотреть сохраненные туры\n3.Изменить пароль\n4.Изменить логин\n5.Удалить учетную запись\n6.Выйти из учетной записи\nВыберите действие: ", 7);
        int userchoice;
        string userchoicesort;
        cin >> userchoice;

        switch (userchoice)
        {
        case 1:

            Findtours(lines, lineCount); // посл поиска сортировка, сохр выбранных  туров

            if (lineCount == 0) {
                printCentered("Туров с таким набором критериев нет", 1);
            }
            else {
                printCentered("НАЙДЕННЫЕ ТУРЫ\n", lineCount + 2);
                printFoundTours(lines, lineCount);
                cout << "\n\n";
                system("pause");
                ifSort(lines, lineCount);
            }
            


            break;
        case 2:
            // просмотреть сохраненные туры
            break;
        case 3:
            //изменить пароль
            changeAccountData("users.txt", currentUserlogin.username, currentUserlogin.password, 2, currentUserlogin);
            break;
        case 4:
            //измеить логин
            changeAccountData("users.txt", currentUserlogin.username, currentUserlogin.password, 1, currentUserlogin);
            break;
        case 5:
            DeleteChoosenUser(1, currentUserlogin.username);
            break;
        case 6:
            //выйти из учет записи
            break;
        default:
            break;
        }
        //мень пользователя(изменить пароль, изменить логин, найти туры, просмотреть сохраненные туры)
    }
    else if (choice == 3) {
        //меню админа (измениь пароль, просмотреть пользователей, просмотреть созраненные туры пользователя, )
        printCentered("1.Редактировать туры\n2.Удалить туры\n3.Добавить туры\n4.Найти туры\n5.Просмотреть пользователей\n6.Удалить пользователz\n7.Добавить пользователя\n8.Просмотрерть сохраненные пользователем туры\nВыберите действие: ", 9);
        int adminchoice;
        cin >> adminchoice;

        switch (adminchoice) {
        case 1:
            //редактировать туры
            break;
        case 2:
            printCentered("1.Удалить неактуальные туры\n2.Удалить выбранный тур\nВыберите действие: ", 3);
            int deletechoice;
            cin >> deletechoice;
            switch (deletechoice)
            {
            case 1:
                // метод ввод сегодняшней даты и удаление строк изфайла
                FindToDeletIrrelevant();
                break;
            case 2:
                DeleteChoosenTour();
                //ввести номер найденного удалчемого тура можно выбрать один или написать диапазон
                break;
            default:
                printCentered("Неправильный выбор", 1);
                break;
            }
            break;
        case 3:
            //добавить тур
            addNewTour("toursmain1.txt", getFieldsOfNewTour());
            break;
        case 4:
            Findtours(lines, lineCount); 
            break;
        case 5:
            ShowUsers();//сделать норм вывод
            break;
        case 6:
            DeleteChoosenUser(0, currentUserlogin.username);
            break;
        case 7:
            addNewData("users.txt", getFieldsOfNewUser());
            break;
        case 8:
            //просмотреть сохр пользователем туры 
            break;
        default:
            break;
        }


    }

    return 0;
}

void ShowUsers() {
    system("cls");
    ifstream file("users.txt");
    if (!file.is_open()) {
        cout << "Файл не открыт";
    }
    int count = 1;
    string line;
    while (getline(file, line)) {

        cout << to_string(count) + ". " + line.substr(0, line.find(' ')) << endl;
        count++;
    }
}

bool isDateInRange(wstring startDate, wstring storedStartDate, wstring storedEndDate) {
    if (startDate != L"любое") {
        storedStartDate = storedStartDate.substr(6, 4) + storedStartDate.substr(3, 2) + storedStartDate.substr(0, 2);
        startDate = startDate.substr(6, 4) + startDate.substr(3, 2) + startDate.substr(0, 2);
        storedEndDate = storedEndDate.substr(6, 4) + storedEndDate.substr(3, 2) + storedEndDate.substr(0, 2);
        return (startDate >= storedStartDate && startDate <= storedEndDate);
    }
    else {
        return L" ";
    }
}

void split(const wstring& input, wstring& storedCityOfDeparture, wstring& storedCountryOfArrival,
    wstring& storedResortCity, wstring& storedStartDate, wstring& storedEndDate, wstring& storedMaxCost) {

    int currentIndex = 0;
    for (int i = 0; i < 6; ++i) {
        wstring substring;

        int nextIndex = input.find(L'/', currentIndex);

        if (nextIndex != -1) {
            substring = input.substr(currentIndex, nextIndex - currentIndex);
            currentIndex = nextIndex + 1;
        }
        else {
            substring = input.substr(currentIndex);
        }

        switch (i) {
        case 0:
            storedCityOfDeparture = substring;
            break;
        case 1:
            storedCountryOfArrival = substring;
            break;
        case 2:
            storedResortCity = substring;
            break;
        case 3:
            storedStartDate = substring;
            break;
        case 4:
            storedEndDate = substring;
            break;
        case 5:
            storedMaxCost = substring;
            break;
        default:
            break;
        }
    }

}

void getSearchCriteria(wstring& departureCity, wstring& arrivalCountry, wstring& resortCity, wstring& startDate, wstring& maxPrice) {
    printCentered("Город отправления (или введите 'любое', если этот критерий поиска не важен): ", 1);
    wcin >> departureCity;
    printCentered("Страна прибытия (или введите 'любое', если этот критерий поиска не важен): ", 1);
    wcin >> arrivalCountry;
    printCentered("Курортный город (или введите 'любое', если этот критерий поиска не важен): ", 1);
    wcin >> resortCity;
    printCentered("Дата отправления (или введите 'любое', если этот критерий поиска не важен): ", 1);
    wcin >> startDate;
    printCentered("Цена (или введите 'любое', если этот критерий поиска не важен): ", 1);
    wcin >> maxPrice;
}

bool isTourMatchingCriteria(wstring& departureCity, wstring& arrivalCountry, wstring& resortCity, wstring& startDate, wstring& maxPrice, wstring& line) {
    wstring storedCityOfDeparture, storedCountryOfArrival, storedResortCity, storedStartDate, storedEndDate, storedMaxCost;
    split(line, storedCityOfDeparture, storedCountryOfArrival, storedResortCity, storedStartDate, storedEndDate, storedMaxCost);
    return ((departureCity == storedCityOfDeparture || departureCity == L"любое") &&
        (arrivalCountry == storedCountryOfArrival || arrivalCountry == L"любое") &&
        (resortCity == storedResortCity || resortCity == L"любое") &&
        (isDateInRange(startDate, storedStartDate, storedEndDate) || startDate == L"любое") &&
        (maxPrice == L"любое" || (stoi(maxPrice) >= stoi(storedMaxCost))));
}

void printFoundTours(wstring** lines, int lineCount) {
    //system("cls");
    //printCentered("НАЙДЕННЫЕ ТУРЫ", lineCount+1);
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);

    int consoleWidth = csbi.srWindow.Right - csbi.srWindow.Left + 1;
    int consoleHeight = csbi.srWindow.Bottom - csbi.srWindow.Top + 1;
    int y = (consoleHeight - lineCount) / 2;
    int linelenght=0;
    for (int i = 0; i < 15; i++) {
        linelenght += lines[0][i].length();
    }
    int x = (consoleWidth - linelenght) / 2;

    for (int i = 0; i < lineCount; ++i) {
        HANDLE consoleHandle = GetStdHandle(STD_OUTPUT_HANDLE);
        COORD cursorPos = { x, y };
        SetConsoleCursorPosition(consoleHandle, cursorPos);
        cout << i+1 << ". ";
        for (int j = 0; lines[i][j] != L""; ++j) {
            wcout << lines[i][j] << " ";
        }
        y++;
    }
}

void ifSort(wstring** lines, int lineCount){

    string userchoicesort; 
    int userchoice, cresing=1;

    system("cls");
    printCentered("Хотите отсортировать туры (да/нет): ", 1);
    cin >> userchoicesort;
    if (userchoicesort == "да") {

        printCentered("Отсортировать можно по:\n1. Цене поезки\n2. Количеству ночей в туре\n3. По  названию отеля\n4. Рейтингу отеля\n5. Типу питания\n6. Линии пляжа\n7. Типу берега\n8. Наличию трансфера\n9. Наличию визы\n10.Типу перемещению\nВыбрете критерий для сортировки: ", 12);
        cin >> userchoice;
        if (userchoice > 6 || userchoice < 0) {
            printCentered("Такого критерия для сортировки нет", 1);
        }
        else {
            printCentered("Вы хотите отсортировать по убыванию или по возрастанию.\nВведите 1, если по убаванию, 2 - по возрастанию: ", 2);
            cin >> cresing;
            while(cresing != 1 && cresing != 2) {
                printCentered("Такого действия нет. Введите занова 1 для сортировки по убыванию, 2 - возрастанию: ", 1);
                cin >> cresing;
            }

            shakerSort(lines, lineCount, userchoice+4, cresing);
            system("cls");
            printCentered("ОТСОРТИРОВАННЫЕ ТУРЫ\n", lineCount + 2);
            printFoundTours(lines, lineCount);

        }
    }
    else if (userchoicesort != "да" && userchoicesort != "нет") {
        printCentered("Такого действия нет", 1);
    }

}

void shakerSort(wstring**& lines, int lineCount, int index, int cresing) {
    bool swapped = true;
    int start = 0;
    int end = lineCount - 1;
    while (swapped) {
        swapped = false;

        for (int i = start; i < end; ++i) {
            switch (cresing)
            {
            case 1:
                if (lines[i][index] > lines[i + 1][index]) {
                    swap(lines[i], lines[i + 1]);
                }
                break;
            case 2:
                if (lines[i][index] < lines[i + 1][index]) {
                    swap(lines[i], lines[i + 1]);
                }
                break;
            }
            swapped = true;
        }

        if (!swapped) {
            break;
        };

        swapped = false;
        --end;

        for (int i = end - 1; i >= start; --i) {
            switch (cresing)
            {
            case 1:
                if (lines[i][index] > lines[i + 1][index]) {
                    swap(lines[i], lines[i + 1]);
                }
                break;
            case 2:
                if (lines[i][index] < lines[i + 1][index]) {
                    swap(lines[i], lines[i + 1]);
                }
                break;
            }
            swapped = true;
        }
        ++start;
    }
}




void Findtours(wstring**& lines, int& lineCount) {
    system("cls");
    wifstream file("toursmain1.txt");
    file.imbue(locale(file.getloc(), new codecvt_utf8<wchar_t>));
    wstring departureCity, arrivalCountry, resortCity, startDate, maxPrice;
    getSearchCriteria(departureCity, arrivalCountry, resortCity, startDate, maxPrice);

    wstring line;


    while (getline(file, line)) {
        if (isTourMatchingCriteria(departureCity, arrivalCountry, resortCity, startDate, maxPrice, line)) {
            addFoundToursInArray(lines, lineCount, line);

        }
    }

    file.close();
}


void addFoundToursInArray(wstring**& lines, int& lineCount, const wstring& line) {
    if (!line.empty()) {
        wstring tempLine = line; 
        wstring* substrings = new wstring[line.size()];
        int substringCount = 0;
        size_t pos = 0;
        while ((pos = tempLine.find(L"/")) != wstring::npos) {
            substrings[substringCount++] = tempLine.substr(0, pos);
            tempLine.erase(0, pos + 1);
        }
        substrings[substringCount++] = tempLine;
        wstring** temp = new wstring * [lineCount + 1];
        copy(lines, lines + lineCount, temp);
        delete[] lines;
        lines = temp;
        lines[lineCount++] = substrings;
    }

}


void FindToDeletIrrelevant() {
    wifstream file("toursmain1.txt");
    file.imbue(locale(file.getloc(), new codecvt_utf8<wchar_t>));
    printCentered("Введите сегодняшнюю дату (в формате дд-мм-гггг): ", 1);
    wstring today, line, storedEndDate;
    wcin >> today;
    today = today.substr(6, 4) + today.substr(3, 2) + today.substr(0, 2);
    int count = 0;
    while (getline(file, line)) {
        storedEndDate = splitEndDate(line);
        if (storedEndDate == L"") {
            printCentered("Хранимая дата окончания тура не получена", 1);
        } else
        if (storedEndDate <= today)
        {
            Deleting(line, "toursmain1.txt");
            count++;
        } 
    }
    if (count == 0) {
        printCentered("Нет неактульных", 1);
    }
    else {
        printCentered("Успешно удалено " + to_string(count) + " туров", 1);
    }

}

wstring splitEndDate(const wstring line) {
    int count = 0, startPos = 0, endPos = 0;

    for (int i = 0; i < line.length(); ++i) {
        if (line[i] == L'/') {
            count++;
            if (count == 4) {
                startPos = i + 1;
                break;
            }
        }
    }

    if (count == 0) {
        return L"";
    }
    else {
        return (line.substr(startPos, 10)).substr(6, 4) + (line.substr(startPos, 10)).substr(3, 2) + (line.substr(startPos, 10)).substr(0, 2);
    }
}

void DeleteChoosenUser(int role, string userlogin) {
    system("cls");
    wifstream file("users.txt");
    wstring login, line;
    if (role == 0) {
        printCentered("Введите логин пользователя, которого желаете удалить: ", 1);
        wcin >> login;
        if (!isUsernameUnique("users.txt", wstringToString(login)))
        {
            while (getline(file, line)) {
                if (login == line.substr(0, line.find(' '))) {
                    Deleting(line, "users.txt");
                    printCentered("Пользователь " + wstringToString(login) + " успешно удален", 1); //переделать так "Пользователь" + login + "успешно удален"
                }
            }
        }
        else {
            printCentered("Пользователя " + wstringToString(login)+ " нет в системе", 1); //переделать так "Пользователь" + login + "успешно удален"

        }
    }
    else {
        printCentered("Вы уверены, что желаете удалить учетную запись (да/нет): ", 1);
        int choice;
        cin >> choice;
        
        switch (choice)
        {
        case 1:
            while (getline(file, line)) {
                if ((stringToWstring(userlogin)) == line.substr(0, line.find(' '))) {
                    Deleting(line, "users.txt");
                    printCentered("Пользователь успешно удален", 1); //переделать так "Пользователь" + login + "успешно удален"
                }
            }
            break;
        case 2:
            break;
        default:
            printCentered("Такого варианта нет", 1);
            break;
        }
    }
}

wstring stringToWstring(const string& str) {
    wstring_convert<codecvt_utf8_utf16<wchar_t>> converter;
    return converter.from_bytes(str);
}

string wstringToString(const wstring& wstr) {
    wstring_convert<codecvt_utf8_utf16<wchar_t>> converter;
    return converter.to_bytes(wstr);
}

void DeleteChoosenTour() {
    system("cls");
    wifstream file("toursmain1.txt");
    file.imbue(locale(file.getloc(), new codecvt_utf8<wchar_t>));
    wstring departureCity, arrivalCountry, resortCity, startDate, maxPrice, line;
    getSearchCriteria(departureCity, arrivalCountry, resortCity, startDate, maxPrice);
    int count = 0;
    while (getline(file, line)) {
        if (isTourMatchingCriteria(departureCity, arrivalCountry, resortCity, startDate, maxPrice, line)) {
            Deleting(line, "toursmain1.txt");
            count++;
        }
    }

    printCentered("Успешно удалено " + to_string(count) + " туров", 1);
    file.close();
}

void Deleting(const wstring& lineToDelete, const string filename) {
    wifstream fileIn(filename);
    fileIn.imbue(locale(fileIn.getloc(), new codecvt_utf8<wchar_t>));
    if (!fileIn.is_open()) {
        cerr << L"Ошибка открытия файла" << endl;
        return;
    }

    wstring line;
    wstring fileContent;
    while (getline(fileIn, line)) {
        if (line != lineToDelete) {
            fileContent += line + L"\n";
        }
    }
    fileIn.close();

    wofstream fileOut(filename);
    fileOut.imbue(locale(fileOut.getloc(), new codecvt_utf8<wchar_t>));
    if (!fileOut.is_open()) {
        cerr << L"Ошибка открытия файла для записи" << endl;
        return;
    }

    fileOut << fileContent;
    fileOut.close();
}

void changeAccountData(const string filename, const string userlogin, const string userpassword, int field, User& currentUser) {// field = 1 изменение логина field = 2 изменение пароля 
    system("cls");
    ifstream file(filename);
    if (!file.is_open()) {
        cerr << "Ошибка открытия файла!" << endl;
        exit(1);
    }
    else {
        string newfield, line;
        if (field == 1) {
            printCentered("Введите новый логин: ", 1);
            cin >> newfield;
            while (getline(file, line)) {
                if (line == userlogin + " " + userpassword) {
                    Deleting(stringToWstring(line), filename);
                }
            }

            while (!isUsernameUnique(filename, newfield)) {
                printCentered("Пользователь с таким логином уже существует. Пожалуйста, выберите другой логин.", 1);
                Sleep(5000);
                printCentered("Введите новый логин: ", 1);
                cin >> newfield;
            }

            //функция добавления нового пользователя которая у админа. передать новый логин и пароль из структуры userpassword
            addNewData("users.txt", (newfield + " " + currentUser.password));
            currentUser.username = newfield;
        }
        else { // зациклить до трях попыток пока два пароля не будут одинаковыми
            printCentered("Введите новый пароль: ", 1);
            cin >> newfield;
            while (getline(file, line)) {
                if (line == userlogin + " " + userpassword) {
                    Deleting(stringToWstring(line), filename);
                }
            }

            string password;
            printCentered("Введите повторно новый пароль", 1);
            cin >> password;

            if (password == newfield) {
                //функция добавления нового пользователя которая у админа. передать логин из структуры userlogin и новый пароль
                addNewData("users.txt", (currentUser.username + " " + newfield));
                currentUser.password = newfield;
            }
            else {
                printCentered("Пароли отличаются", 1);
            }
        }
    }
}

string getFieldsOfNewUser() {
    string loginofnewuser, passwordofnewuser;
    printCentered("Введите логин добавляемого пользователя: ", 1);
    cin >> loginofnewuser;
    while (!isUsernameUnique("users.txt", loginofnewuser)) {
        printCentered("Пользователь с таким логином уже существует. Пожалуйста, выберите другой логин.\nВведите логин добавляемого пользователя: ", 1);
        cin >> loginofnewuser;
    }
    printCentered("Введите пароль добавляемого пользователя: ", 1);
    cin >> passwordofnewuser;
    return (loginofnewuser + " " + passwordofnewuser);
}

void addNewData(const string filename, string addedline) {
    ofstream file(filename, ios::app);

    if (!file.is_open()) {
        cerr << "Ошибка открытия файла!" << endl;
        exit(1);
    }
    else {
        file << addedline << endl;
    }
}


void addNewTour(const string filename, wstring addedline) {
    wofstream file(filename, ios::app);
    file.imbue(locale(file.getloc(), new codecvt_utf8<wchar_t>));
    if (!file.is_open()) {
        wcerr << "Ошибка открытия файла!" << endl;
        exit(1);
    }
    else {
        file << addedline;
    }
}

wstring getFieldsOfNewTour() {
    wstring data, input;
    string chaicecontinue = "да", choiceadd;
    int countofadd = 0;
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi);

    int consoleWidth = csbi.srWindow.Right - csbi.srWindow.Left + 1;
    int consoleHeight = csbi.srWindow.Bottom - csbi.srWindow.Top + 1;
    while (chaicecontinue == "да") {
        for (int i = 1; i < 16; i++) {
            switch (i)
            {
            case 1:
                getline(wcin, data);
                printCentered("Введите город отправления: ", 1);
                getline(wcin, data);
                break;
            case 2:
                printCentered("Введите страну прибытия: ", 1);
                getline(wcin, data);
                break;
            case 3:
                printCentered("Введите курортный город: ", 1);
                getline(wcin, data);
                break;
            case 4:
                printCentered("Введите дату первого отправления: ", 1);
                getline(wcin, data);
                break;
            case 5:
                printCentered("Введите дату последнего отправления: ", 1);
                getline(wcin, data);
                break;
            case 6:
                printCentered("Введите цену: ", 1);
                getline(wcin, data);
                break;
            case 7:
                printCentered("Введите количество ночей: ", 1);
                getline(wcin, data);
                break;
            case 8:
                printCentered("Введите название отеля: ", 1);
                getline(wcin, data);
                break;
            case 9:
                printCentered("Введите рейтинг отеля: ", 1);
                getline(wcin, data);
                break;
            case 10:
                printCentered("Введите тип питания: ", 1);
                getline(wcin, data);
                break;
            case 11:
                printCentered("Введите линию пляжа: ", 1);
                getline(wcin, data);
                break;
            case 12:
                printCentered("Введите тип берега: ", 1);
                getline(wcin, data);
                break;
            case 13:
                printCentered("Введите наличие трансфера: ", 1);
                getline(wcin, data);
                break;
            case 14:
                printCentered("Введите необходимость в наличии визы: ", 1);
                getline(wcin, data);
                break;
            case 15:
                printCentered("Введите тип перемещения: ", 1);
                getline(wcin, data);
                break;
            default:
                break;
            }
            input += data + L"/";
        }

        wstring test = input + L"\n";
        system("cls");


        int posY = (consoleHeight - countofadd + 1) / 2;
        int posX = 0;
        for (int i = 0; i <= countofadd; i++) {
            posX = (consoleWidth - (test.substr(0, test.find(L'\n'))).length()) / 2;
            COORD cursorPos = { posX, posY };
            SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cursorPos);

            wcout << test.substr(0, test.find(L'\n'));
            test = test.substr(test.find(L'\n') + 1);
            posY++;
            if (i == countofadd) {
                
                const string d = "Вы уверены, что хотите добавить последний введенный тур (да/нет): ";
                posX = (consoleWidth - d.length()) / 2;
                COORD cursorPos = { posX, posY };
                SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), cursorPos);
                cout << d;
            }  
        }

        cin >> choiceadd;
        printCentered("Желаете добавить еще (да/нет): ", 1);
        cin >> chaicecontinue;
        
        if (choiceadd == "нет" && chaicecontinue == "нет") {
            input= L"";
            break;
        }
        else if (choiceadd == "нет" && chaicecontinue == "да") {
            if (countofadd == 0) {
                input = L"";
            }
            else {
                input = input.substr(0, input.find_last_of(L"\n")+1);
            }
            
        } if (choiceadd == "да" && chaicecontinue == "да") {
            input += L"\n";
            countofadd++;
        }
    
    }
    return L"\n"+input;
}

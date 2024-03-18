//1
function writePetyafromJSON() {
const jsonString = '["Коля", "Вася", "Петя"]';
const jsonArray = JSON.parse(jsonString);

console.log(jsonArray[2]); // Выведет "Петя"

}

//2
function docWriteStr() {
for (let i = 1; i <= 9; i++) {
	for (let j = 1; j <= 3; j++) {
		document.write(i);
	}
}
}

//3
 function calculateSquare() {
    const inputValue = parseFloat(document.getElementById('numberInput').value);
	let resultValue = Math.pow(inputValue, 2);
    if (!isNaN(inputValue)) {
        alert(`Квадрат числа ${inputValue} равен ${resultValue}`);
    } else {
        alert('Пожалуйста, введите корректное число.');
    }
}

//4
function addRow() {
            const table = document.getElementById("memberTable");
            const rowCount = table.rows.length;

            const row = table.insertRow(rowCount);

            const cell1 = row.insertCell(0);
            const cell2 = row.insertCell(1);
            const cell3 = row.insertCell(2);

            cell1.innerHTML = '<input type="text" value="' + rowCount + '" disabled>';
            cell2.innerHTML = '<input type="text" placeholder="Имя">';
            cell3.innerHTML = '<input type="text" placeholder="Фамилия">';
        }
	
//5	
		 function validateData() {
            const rows = document.querySelectorAll("#memberTable tr");
            let isValid = true;

            rows.forEach((row, index) => {
                if (index > 0) {
                    const nameInput = row.querySelector("input:nth-child(2)");
                    const surnameInput = row.querySelector("input:nth-child(3)");

                    if (nameInput == null || surnameInput == null) {
                        isValid = false;
                    } else if (nameInput.value.length < 2 || surnameInput.value.length < 2) {
                        isValid = false;
                    }
                }
            });

            if (isValid) {
                alert("Успешно");
            } else {
                alert("Не выполнены все условия заполнения таблицы");
            }
        }
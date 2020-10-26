import Config from './config';

window.addEventListener('message', (event) => {
    switch (event.data.action) {
        case 'setup':
            SetupData(event.data.data);
            break;
        case 'logout':
            ClearData();
            break;
    }
});

function SetupData(data) {
    $.each(data, (index, item) => {
        window.localStorage.setItem(item.name, JSON.stringify(item.data));
    });
}

function StoreData(name, data) {
    window.localStorage.setItem(name, JSON.stringify(data));
}

function AddData(name, value) {
    let arr = GetData(name);
    arr.push(value);
    StoreData(name, arr);
}

function RemoveData(name, index) {
    let arr = GetData(name);
    arr.splice(index, 1);
    StoreData(name, arr);
}

function RemoveObjectData(name, key, value) {
    let arr = GetData(name);
    $.each(arr, (index, item) => {
        if (item[key] == value) {
            RemoveData(name, index);
            return false;
        }
    });
}

function UpdateData(name, index, data) {
    let arr = GetData(name);
    arr[index] = data;
    StoreData(name, arr);
}

function UpdateObjectData(name, searchKey, searchValue, updateKey, updateValue) {
    let arr = GetData(name);
    $.each(arr, (index, item) => {
        if (item[searchKey] == searchValue) {
            arr[index][updateKey] = updateValue;
            StoreData(name, arr);
            return false;
        }
    });
}

function GetData(name) {
    return JSON.parse(window.localStorage.getItem(name));
}

function StoreDataLua(key, data) {
    $.post(Config.ROOT_ADDRESS + '/RegiseterData', JSON.stringify({
        key: key,
        data: data
    }));
}

function GetDataLua(key) {
    $.post(Config.ROOT_ADDRESS + '/GetData', JSON.stringify({
        key: key
    }), (data) => {
        return data
    });
}

function ClearData() {
    window.localStorage.clear();
}

export default { SetupData, StoreData, AddData, RemoveData, RemoveObjectData, UpdateData, UpdateObjectData, GetData, ClearData, StoreDataLua, GetDataLua, };

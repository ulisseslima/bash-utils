// https://pt.stackoverflow.com/questions/244457/gerador-de-cpf-em-javascript

function gerarCpf() {
var num1 = aleatorio().toString();
var num2 = aleatorio().toString();
var num3 = aleatorio().toString();

var dig1 = digPri(num1,num2,num3);
var dig2 = digSeg(num1,num2,num3,dig1);
var cpf= num1+"."+num2+"."+num3+"-"+dig1+""+dig2;
console.log(cpf);
return cpf;
}


function digPri(n1,n2,n3) {
var nn1 = n1.split("");
var nn2 = n2.split("");
var nn3 = n3.split("");
var nums = nn1.concat(nn2,nn3);

var x = 0;
var j = 0;
for (var i=10;i>=2;i--) {
    x += parseInt(nums[j++]) * i;
}
var y = x % 11;
if (y < 2) {
    return 0;
} else {
    return 11-y;
}}

function digSeg(n1,n2,n3,n4) {
var nn1 = n1.split("");
var nn2 = n2.split("");
var nn3 = n3.split("");
var nums = nn1.concat(nn2,nn3);
nums[9] = n4;
var x = 0;
var j = 0;
for (var i=11;i>=2;i--) {
    x += parseInt(nums[j++]) * i;
}
var y = x % 11;
if (y < 2) {
    return 0;
} else {
    return 11-y;
}}

function aleatorio() {
var aleat = Math.floor(Math.random() * 999);
if (aleat < 100) {
    if (aleat < 10) {
        return "00"+aleat;
    } else {
        return "0"+aleat;
    }
} else {
    return aleat;
}}

gerarCpf();

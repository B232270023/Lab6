# Lab 06 — Category-Partition ба PICT

**Оюутан:** Shinebayar  
**Код:** B232270023

## Хэсэг A — Category-Partition

### A1. Сонголт ба төлөөлөх утгууд

| Параметр | Сонголт | Төлөөлөх утга, setup |
|---|---|---|
| from | Valid | Байгаа, царцаагаагүй данс `F1` |
| from | Frozen | Байгаа боловч царцаасан `F1` |
| from | Missing | Байхгүй `FROM-X` ID |
| to | Valid | Байгаа бөгөөд from-оос өөр `T1` данс |
| to | Missing | Байхгүй `TO-X` ID |
| to | SameAsFrom | `to` нь `from`-той ижил ID |
| amount | Normal | Эерэг; үлдэгдэл болон өдрийн үлдсэн лимитээс бага |
| amount | Zero | Тэг (сөрөг утга мөн `amount ≤ 0` ангилалд хамаарна) |
| amount | OverBalance | Хөрвүүлсний дараах эерэг дүн from дансны үлдэгдлээс их |
| amount | OverLimit | Хөрвүүлсний дараах эерэг дүн өдрийн үлдсэн лимитээс их |
| currency | Same | Хүлээн авагч дансны валюттай адил |
| currency | Different | Дансны валютаас ялгаатай; ханшийн хөрвүүлэлт хийнэ |

Далд орчны сонголт нь данс байгаа эсэх, царцаалт, from дансны үлдэгдэл, тухайн өдрийн өмнөх шилжүүлэг буюу үлдсэн лимит, мөн валютын ханш юм. Amount-ийн ангиллыг тодорхойлоход эдгээрийг setup-д тогтооно; ханш ба дансны валютыг сонгосноор Same/Different нөхцөл тогтоно.

### A2. Хязгаарлалт

| Сонголтын хослол | Тэмдэглэгээ | Үндэслэл |
|---|---|---|
| From=Valid | [SINGLE] | Суурь амжилтын мөрөнд ганц хэвийн from нөхцөлийг төлөөлүүлнэ. |
| From=Frozen | [ERROR] | Царцаалт нь `ERROR_FROZEN` үүсгэх ганц сөрөг шалтгаан байна. |
| From=Missing | [ERROR] | Байхгүй эх үүсвэр `ERROR_NO_FROM` үүсгэнэ. |
| To=Valid | [SINGLE] | Суурь амжилтад тусдаа, хүчинтэй хүлээн авагч ашиглана. |
| To=Missing | [ERROR] | Байхгүй хүлээн авагч `ERROR_NO_TO` үүсгэнэ. |
| To=SameAsFrom | [ERROR] | Ижил данс `ERROR_SAME_ACCOUNT` үүсгэнэ. |
| Amount=Normal | [SINGLE] | Эерэг, хүрэлцэх үлдэгдэлтэй, лимитэд багтсан утга амжилтын жишиг болно. |
| Amount=Zero | [ERROR] | Тэг (мөн сөрөг) дүн `ERROR_BAD_AMOUNT` болно. |
| Amount=OverBalance | [ERROR] | Хөрвүүлсний дараах үлдэгдлээс их дүн `ERROR_INSUFFICIENT` болно. |
| Amount=OverLimit | [ERROR] | Хөрвүүлсний дараах өдрийн үлдсэн лимитээс их дүн `ERROR_LIMIT` болно. |
| Currency=Same | [SINGLE] | Хөрвүүлэлтгүй суурь тохиолдол. |
| Currency=Different | [IF/property] | Өөр валют сонговол ханшийг хэрэглэж, үлдэгдэл ба лимитийг хөрвүүлсний дараа шалгана. |
| From=Missing ⇒ To≠SameAsFrom | [IF/property] | Байхгүй эх данстай бодит ижил дансны харьцаа тодорхойлогдохгүй. |
| To=SameAsFrom ⇒ From=Valid | [IF/property] | Ижил дансны сонголтыг бодит, байгаа дансаар л утгатай тодорхойлно. |

Шууд үржвэрийн бүрэн олонлог: `3 × 3 × 4 × 2 = 72`. `From=Missing` үед `To=SameAsFrom` боломжгүй (эх ID огт байхгүй), мөн `To=SameAsFrom` бол `From=Valid` байх ёстой гэж үзсэн хоёр IF дүрэм нийлээд 16 хослолыг хасна: `(From=Missing, To=SameAsFrom)`-ийн 8 amount/currency хослол ба `(From=Frozen, To=SameAsFrom)`-ийн 8 хослол. Иймээс хязгаарлалтын дараа `72 → 56` хүчинтэй комбинац үлдэнэ. Энэ нь full factorial утгын хослолын тоо; PICT-ийн pairwise гаралтын мөрийн тоо өөр бөгөөд `results/transfer.txt`-ийн толгой мөрийг хасаж тоолно. IF нь зөвхөн утгагүй дансны харилцааг хасна; зориудын A3 олон алдааны мөрүүдийг хадгална.

Олон алдаа давхацвал дараах oracle эрэмбийг хэрэглэнэ: **from (NO_FROM → FROZEN) → to (NO_TO → SAME_ACCOUNT) → amount (BAD_AMOUNT → INSUFFICIENT → LIMIT)**. Тодорхойлолт эрэмбийг заагаагүй тул энэ нь тестийн таамаг бөгөөд бодит хэрэгжүүлэлтийн баталгаа биш.

### A3. Гараар боловсруулсан спецификаци

| # | From | To | Amount | Currency | Хүлээгдэх үр дүн |
|---:|---|---|---|---|---|
| 1 | Valid | Valid | Normal | Same | `201 {"result":"OK"}` |
| 2 | Missing | Valid | Normal | Same | `200 {"result":"ERROR_NO_FROM"}` |
| 3 | Frozen | Valid | Normal | Same | `200 {"result":"ERROR_FROZEN"}` |
| 4 | Valid | Missing | Normal | Same | `200 {"result":"ERROR_NO_TO"}` |
| 5 | Valid | SameAsFrom | Normal | Same | `200 {"result":"ERROR_SAME_ACCOUNT"}` |
| 6 | Valid | Valid | Zero | Same | `200 {"result":"ERROR_BAD_AMOUNT"}` |
| 7 | Valid | Valid | OverBalance | Same | `200 {"result":"ERROR_INSUFFICIENT"}` |
| 8 | Valid | Valid | OverLimit | Same | `200 {"result":"ERROR_LIMIT"}` |
| 9 | Valid | Valid | Normal | Different | `201 {"result":"OK"}`; ханш хэрэглэж, хөрвүүлсэн дүн лимитэд багтана |
| 10 | Missing | Missing | Normal | Same | `200 {"result":"ERROR_NO_FROM"}` (from эхэлж шалгана) |
| 11 | Valid | Missing | Zero | Same | `200 {"result":"ERROR_NO_TO"}` (to нь amount-аас өмнө) |
| 12 | Frozen | SameAsFrom | Normal | Same | `200 {"result":"ERROR_FROZEN"}` (from-ийн эрэмбэ to-оос өмнө) |

## Хэсэг B — PICT

PICT эх кодыг даалгаврын дагуу энэ репогийн гадна (`~/tools/pict`) build хийнэ. `scripts/run-pict.sh` нь build-ийн commit/help нотолгоо болон таван model-ийн гаралтыг `results/`-д үүсгэж, header-гүй мөрийн тоог хэвлэнэ. Ubuntu дээр:

```sh
cd ~/tools/pict
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j4
cd /path/to/Lab6
bash scripts/run-pict.sh
```

Лабын PICT хязгаарлалттай орчинд одоогоор ажиллуулаагүй тул шаардагдах `results/*.txt`, pairwise мөрийн тоо, happy-path болон нэг мөр дэх сөрөг утгын шинжилгээг бодит гаралт авсны дараа энд тайлагнана. Энэ README-д ажиллуулаагүй тоог таамаглан оруулаагүй.

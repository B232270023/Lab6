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

Шууд үржвэрийн бүрэн олонлог: `3 × 3 × 4 × 2 = 72`. Дээрх хоёр утгат IF хязгаарлалт PICT-ийн transfer model-д мөн тавигдах ба үлдэх хослолын тоог PICT ажиллуулсны дараа `results/transfer.txt`-ээс тооцно (`72 → [ажиллуулсны дараа бөглөнө]`). IF нь зөвхөн утгагүй төлөвүүдийг хасна; өөр өөр алдааны ангийг зориуд хавсаргасан A3 мөрүүдийг устгахгүй.

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

PICT болон model-ийн бодит гаралтыг үүсгэсний дараа энэ хэсгийг мөрийн тоо, гаралтаар бүрэн бөглөнө.


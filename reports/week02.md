

## Диаграмма
См. `er_diagram.png` (исходник `er_diagram.dbml`). Всего 11 таблиц.
Связи «многие ко многим» развёрнуты в ассоциативные таблицы:
- `user_roles` (users ↔ roles), собственный атрибут: `assigned_at`;
- `master_services` (masters ↔ services), собственные атрибуты: `price`, `duration_min`.

Таблица-факт: `appointments`. К неделе 4 она вырастет до 300 000 строк (на диаграмме выделена красным).

## Проверка на 3НФ: таблица appointments

### Первый набросок (до)
appointments_v1(id, client_id, client_phone, master_id, salon_id, salon_address, service_id, service_name, start_at, status)

Первичный ключ: id. Транзитивные зависимости (неключевой атрибут зависит от другого неключевого):
- id → master_id → salon_id (салон определяется мастером);
- id → salon_id → salon_address;
- id → service_id → service_name;
- id → client_id → client_phone.

Аномалии:
- обновления: при смене адреса салона пришлось бы править тысячи строк записей;
- удаления: если удалить последнюю запись салона, пропадёт его адрес;
- вставки: нельзя сохранить новую услугу или салон, пока нет записи, в которой они участвуют.

### Исправленная таблица (после)
appointments(id, client_id, master_id, service_id, start_at, end_at, status, price_total, created_at)

Убраны salon_id, salon_address, client_phone, service_name: они доступны через связи masters.salon_id → salons, users.phone, services.name.
Теперь каждый неключевой атрибут зависит только от id (2НФ выполняется, так как ключ простой).
Транзитивной зависимости нет: client_id, master_id, service_id — это ссылки, а start_at, end_at, status, price_total описывают именно эту запись.

Замечание про price_total: цена на момент записи сохраняется намеренно. Прайс мастера может измениться, а история записей должна остаться прежней, поэтому это не избыточность, а факт.

### Дополнительный пример: reviews
В reviews хранится только appointment_id, а клиент и мастер получаются через appointments. Если бы в reviews были client_id и master_id, появилась бы транзитивная зависимость appointment_id → client_id.
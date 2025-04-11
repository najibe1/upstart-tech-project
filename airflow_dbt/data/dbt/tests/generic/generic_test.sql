{% test generic_test (model, query, days_behind) %}
{{ config(severity='warn') }}

{% if days_behind is defined %}
WITH tmp_variable AS (
    SELECT DATE_SUB(CURRENT_TIMESTAMP(), INTERVAL {{ days_behind }} DAY) AS begin_date
    ),
    main_query AS(
        {{ query }}
    )

SELECT * FROM main_query

{% else %}

{{ query }}

{% endif %}

{% endtest %}
FROM swipl
COPY . /app
CMD ["swipl", "./app/start.pl"]
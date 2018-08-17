FROM couchbase:community-4.1.1 
COPY setup.sh ./
CMD ["./setup.sh"]

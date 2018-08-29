FROM couchbase:community-5.1.1 
COPY setup.sh ./
CMD ["./setup.sh"]

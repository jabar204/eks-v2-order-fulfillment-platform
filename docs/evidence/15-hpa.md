NAME                   REFERENCE                         TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
api-gateway            Deployment/api-gateway            cpu: 1%/70%   2         10        2          40m
dashboard-api          Deployment/dashboard-api          cpu: 1%/70%   2         10        2          40m
inventory-service      Deployment/inventory-service      cpu: 1%/70%   2         10        2          40m
keda-hpa-worker        Deployment/worker                 0/5 (avg)     1         10        1          40m
notification-service   Deployment/notification-service   cpu: 1%/70%   2         10        2          40m
order-service          Deployment/order-service          cpu: 1%/70%   2         10        2          40m
payment-service        Deployment/payment-service        cpu: 1%/70%   2         10        2          40m
shipping-service       Deployment/shipping-service       cpu: 1%/70%   2         10        2          40m


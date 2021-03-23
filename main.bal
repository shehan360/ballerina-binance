import ballerina/io;
import ballerina/websocket;
import ballerina/http;

public function main() returns error? {
    websocket:Client wsClient = check new ("wss://dex.binance.org/api/ws/$all@allTickers");
    http:Client clientEndpoint = check new ("https://api.binance.com");

    io:println(wsClient.isOpen());
    string textResp = check wsClient->readTextMessage();
    json resJson = check textResp.fromJsonString();

    json[] data = <json[]> checkpanic resJson.data;
    foreach var crncy in data {
        string symbol = check crncy.s;
        string percentageStr = check crncy.P;
        float percentage = check float:fromString(percentageStr);
        if (percentage >= .5) {
            io:println("Currency: ", symbol, " Pecentage: ", percentage);
            json orderjson = {"symbol":symbol, "quantity": 1};
            http:Response post = check clientEndpoint->post("/api/v3/order/test", orderjson);
            io:println(post.getJsonPayload());
            io:println("Order palced!");
        }
    }
    
    websocket:Error? close = wsClient->close();

}

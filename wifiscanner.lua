function listAP(x)
    for k, v in pairs(x) do
        print(k.. " : " ..v)
    end
end

wifi.sta.getap(listAP)
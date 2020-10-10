load('api_gpio.js');
load('api_timer.js');
load('api_sys.js');
load('api_bt_gatts.js');
load('api_config.js');

let PIN = {
  UP: 13,
  DOWN: 12,
};

let DIRECTION = {
  UP: 'UP',
  DOWN: 'DOWN',
  NONE: 'NONE',
};

let currentDirection = DIRECTION.NONE;

let setDirection = function (direction) {
  if (direction === DIRECTION.UP) {
    GPIO.write(PIN.DOWN, false);
    GPIO.write(PIN.UP, true);
    currentDirection = DIRECTION.UP;
  } else if (direction === DIRECTION.DOWN) {
    GPIO.write(PIN.UP, false);
    GPIO.write(PIN.DOWN, true);
    currentDirection = DIRECTION.DOWN;
  } else {
    GPIO.write(PIN.UP, false);
    GPIO.write(PIN.DOWN, false);
    currentDirection = DIRECTION.NONE;
  }
};

GPIO.set_mode(PIN.UP, GPIO.MODE_OUTPUT);
GPIO.set_mode(PIN.DOWN, GPIO.MODE_OUTPUT);

GATTS.registerService(
  '7ad74b14-2692-45b3-89a6-84dc264526f7',
  GATT.SEC_LEVEL_NONE,
  [
    ["4559a45a-41c0-454a-8574-91324d1007c5", GATT.PROP_RWNI(1, 1, 0, 0)],
  ],
  function (connection, event, argument) {
    if (event === GATTS.EV_CONNECT) {
      print('CONNECTED: ', connection.addr);
      return GATT.STATUS_OK;
    } else if (event === GATTS.EV_READ) {
      // Send current direction
      GATTS.sendRespData(connection, argument, currentDirection);
      return GATT.STATUS_OK;
    } else if (event === GATTS.EV_WRITE) {
      if (argument.data === DIRECTION.UP) {
        setDirection(DIRECTION.UP);
      } else if (argument.data === DIRECTION.DOWN) {
        setDirection(DIRECTION.DOWN);
      } else {
        setDirection();
      }

      print('DIRECTION: ', argument.data || DIRECTION.NONE);
      GATTS.sendRespData(connection, argument, argument.data);

      return GATT.STATUS_OK;
    } else if (event === GATTS.EV_DISCONNECT) {
      print('DISCONNECTED: ', connection.addr);
      return GATT.STATUS_OK;
    }
    return GATT.STATUS_REQUEST_NOT_SUPPORTED;
  }
);

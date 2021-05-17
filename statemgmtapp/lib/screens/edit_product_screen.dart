import 'package:flutter/material.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';

class EditProductsScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  final _pricefocusnode = FocusNode();
  final _descriptionfocusnode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formkey = GlobalKey<FormState>();
  var editedProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');

  var _initvalues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isinit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateimageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isinit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initvalues = {
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price.toString(),
          //  'imageUrl': editedProduct.imageUrl,
        };
        _imageUrlController.text = editedProduct.imageUrl;
      }
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  void _updateimageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) &&
          (!_imageUrlController.text.endsWith('png') ||
              !_imageUrlController.text.endsWith('jpg') ||
              !_imageUrlController.text.endsWith('jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  void dispose() {
    _imageUrlFocusNode.removeListener(_updateimageUrl);
    _pricefocusnode.dispose();
    _descriptionfocusnode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveform() async{
    final isValid = _formkey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formkey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(editedProduct.id, editedProduct);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(editedProduct)
          .catchError((error) {
       return showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error has occured'),
                  content: Text('Something went wrong.'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: (){
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ));
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveform,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formkey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initvalues['title'],
                      decoration: InputDecoration(labelText: 'title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_pricefocusnode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          id: editedProduct.id,
                          title: value,
                          description: editedProduct.description,
                          price: editedProduct.price,
                          imageUrl: editedProduct.imageUrl,
                          isFavorite: editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initvalues['price'],
                      decoration: InputDecoration(labelText: 'price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _pricefocusnode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionfocusnode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'please enter a valid price';
                        }
                        if (double.parse(value) <= 0) {
                          return 'please enter a valid price';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          id: editedProduct.id,
                          title: editedProduct.title,
                          description: editedProduct.description,
                          price: double.parse(value),
                          imageUrl: editedProduct.imageUrl,
                          isFavorite: editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initvalues['description'],
                      decoration: InputDecoration(labelText: 'description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionfocusnode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please enter a value';
                        }
                        if (value.length < 10) {
                          return 'please enter a brief description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          id: editedProduct.id,
                          title: editedProduct.title,
                          description: value,
                          price: editedProduct.price,
                          imageUrl: editedProduct.imageUrl,
                          isFavorite: editedProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          )),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter A Url')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Image Url:'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onEditingComplete: () {
                              setState(
                                () {},
                              );
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'please enter a url';
                              }
                              if (!value.startsWith('http') &&
                                  (!value.startsWith('https'))) {
                                return 'please add a valid url';
                              }
                              if (!value.endsWith('png') &&
                                  !value.endsWith('jpg') &&
                                  !value.endsWith('jpeg')) {
                                return 'please add png,jpg or jpeg format picture';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _saveform();
                            },
                            onSaved: (value) {
                              editedProduct = Product(
                                id: editedProduct.id,
                                title: editedProduct.title,
                                description: editedProduct.description,
                                price: editedProduct.price,
                                imageUrl: value,
                                isFavorite: editedProduct.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
